///|
fn sign(ordering : Ordering) -> Int {
  match ordering {
    Less => -1
    Equal => 0
    Greater => 1
  }
}

///|
fn law_corpus() -> Array[String] {
  [
    "", "a", "A", "á", "a\u{0301}", "ä", "å", "æ", "b", "B", "co-op", "coop",
    "file2", "file10", "ß", "ss", "Ω", "ω", "й", "и\u{0306}", "東京", "文件",
    "서울", "\u{1F600}", "\u{1ACF}\u{0334}", "\u{10FFFF}",
  ]
}

///|
test "comparison is reflexive across a mixed corpus" {
  let collator = default_collator()
  for value in law_corpus() {
    assert_eq(collator.compare(value, value), Ordering::Equal)
  }
}

///|
test "comparison is antisymmetric across a mixed corpus" {
  let collator = default_collator()
  let corpus = law_corpus()
  for left in corpus {
    for right in corpus {
      assert_eq(
        sign(collator.compare(left, right)),
        0 - sign(collator.compare(right, left)),
      )
    }
  }
}

///|
test "key comparison and direct comparison agree" {
  let configurations = [
    default_collator(),
    default_collator().with_strength(Strength::Primary),
    default_collator().with_strength(Strength::Secondary),
    default_collator().with_alternate(AlternateHandling::Shifted),
    default_collator().with_numeric(true),
  ]
  let corpus = law_corpus()
  for collator in configurations {
    for left in corpus {
      for right in corpus {
        let direct = collator.compare(left, right)
        let reported = collator.compare_detailed(left, right).ordering()
        assert_eq(direct, reported)
        assert_eq(
          collator.compare_detailed(left, right).left_key(),
          collator.sort_key(left),
        )
      }
    }
  }
}

///|
test "stable sorted output is monotonic" {
  let collators = [
    default_collator(),
    default_collator().with_strength(Strength::Primary),
    default_collator().with_alternate(AlternateHandling::Shifted),
    default_collator().with_numeric(true),
  ]
  for collator in collators {
    let sorted = collator.sort(law_corpus())
    assert_true(collator.is_sorted(sorted))
    for index = 1; index < sorted.length(); index = index + 1 {
      assert_true(collator.compare(sorted[index - 1], sorted[index]) != Greater)
    }
  }
}

///|
test "NFD implementation is idempotent" {
  for value in law_corpus() {
    let once = default_collator().explain(value).normalized()
    let twice = default_collator().explain(once).normalized()
    assert_eq(once, twice)
  }
}

///|
test "canonical equivalents share every key level" {
  let pairs = [
    ("é", "e\u{0301}"),
    ("Å", "A\u{030A}"),
    ("ñ", "n\u{0303}"),
    ("가", "\u{1100}\u{1161}"),
    ("각", "\u{1100}\u{1161}\u{11A8}"),
  ]
  let collator = default_collator().with_strength(Strength::Identical)
  for pair in pairs {
    let (left, right) = pair
    assert_eq(collator.sort_key(left), collator.sort_key(right))
    assert_eq(collator.compare(left, right), Ordering::Equal)
  }
}

///|
test "Unicode 17 combining classes participate in canonical ordering" {
  let left = "\u{1ACB}\u{0334}"
  let right = "\u{1ACF}\u{0334}"
  assert_eq(default_collator().explain(left).normalized(), "\u{0334}\u{1ACB}")
  assert_eq(default_collator().explain(right).normalized(), "\u{0334}\u{1ACF}")
  assert_eq(
    default_collator().with_strength(Strength::Identical).compare(left, right),
    Ordering::Less,
  )
}

///|
test "discontiguous contractions preserve canonical equivalence" {
  let collator = default_collator()
  let contiguous = "и\u{0306}\u{0334}"
  let reordered = "и\u{0334}\u{0306}"
  assert_eq(collator.sort_key(contiguous), collator.sort_key(reordered))
}

///|
test "implicit ranges remain ordered at Unicode boundaries" {
  let collator = default_collator()
  assert_eq(collator.compare("\u{187FF}", "\u{18D00}"), Ordering::Less)
  assert_eq(collator.compare("\u{18AFF}", "\u{18D80}"), Ordering::Less)
  assert_eq(collator.compare("\u{F9E9}", "\u{3400}"), Ordering::Less)
  assert_eq(collator.compare("\u{33479}", "\u{0378}"), Ordering::Less)
  assert_eq(collator.compare("\u{2A6E0}", "\u{2B81E}"), Ordering::Less)
}

///|
test "very long numeric runs do not overflow" {
  let collator = default_collator().with_numeric(true)
  let small = "n99999999999999999999999999999999999999"
  let large = "n100000000000000000000000000000000000000"
  assert_eq(collator.compare(small, large), Ordering::Less)
}

///|
test "leading numeric zeroes stay equal below identical strength" {
  let collator = default_collator().with_numeric(true)
  assert_eq(collator.compare("item2", "item002"), Ordering::Equal)
  assert_eq(
    collator.with_strength(Strength::Identical).compare("item2", "item002"),
    Ordering::Greater,
  )
}
