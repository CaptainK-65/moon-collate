///|
test "sort returns a new stable ordered array" {
  let source = ["éclair", "eagle", "Éclair", "apple"]
  let sorted = default_collator().sort(source)
  assert_eq(sorted, ["apple", "eagle", "éclair", "Éclair"])
  assert_eq(source, ["éclair", "eagle", "Éclair", "apple"])
}

///|
test "numeric collection sort handles digit runs" {
  let source = ["file20", "file3", "file10", "file1"]
  let sorted = default_collator().with_numeric(true).sort(source)
  assert_eq(sorted, ["file1", "file3", "file10", "file20"])
}

///|
test "is_sorted accepts equals and rejects inversions" {
  let collator = default_collator()
  assert_true(collator.is_sorted([]))
  assert_true(collator.is_sorted(["a"]))
  assert_true(collator.is_sorted(["a", "b", "c"]))
  assert_false(collator.is_sorted(["b", "a", "c"]))
}

///|
test "primary groups preserve input order among equals" {
  let collator = default_collator().with_strength(Strength::Primary)
  let groups = collator.group_equal(["É", "e", "E", "f", "é"])
  assert_eq(groups.length(), 2)
  assert_eq(groups[0].representative(), "É")
  assert_eq(groups[0].values(), ["É", "e", "E", "é"])
  assert_eq(groups[0].length(), 4)
  assert_eq(groups[1].values(), ["f"])
}

///|
test "deduplicate retains first representative" {
  let collator = default_collator().with_strength(Strength::Primary)
  assert_eq(collator.deduplicate(["résumé", "resume", "Resume", "work"]), [
    "résumé", "work",
  ])
}

///|
test "minimum and maximum support empty and populated arrays" {
  let collator = default_collator()
  assert_eq(collator.minimum([]), None)
  assert_eq(collator.maximum([]), None)
  assert_eq(collator.minimum(["z", "a", "m"]), Some("a"))
  assert_eq(collator.maximum(["z", "a", "m"]), Some("z"))
  assert_eq(collator.maximum(["a", "m", "z"]), Some("z"))
}

///|
test "stable sort handles collation-equal neighbors" {
  let collator = default_collator().with_strength(Strength::Primary)
  assert_eq(collator.sort(["é", "E", "e"]), ["é", "E", "e"])
}

///|
test "collation index sorts once and searches equal ranges" {
  let collator = default_collator().with_strength(Strength::Primary)
  let index = CollationIndex::new(collator, ["Zulu", "é", "E", "apple", "e"])
  assert_eq(index.length(), 5)
  assert_false(index.is_empty())
  assert_eq(index.values(), ["apple", "é", "E", "e", "Zulu"])
  assert_true(index.contains("É"))
  assert_false(index.contains("missing"))
  assert_eq(index.equal_range("é"), ["é", "E", "e"])
  assert_eq(index.lower_bound("é"), 1)
  assert_eq(index.upper_bound("é"), 4)
}

///|
test "empty collation index has zero-width searches" {
  let index = CollationIndex::new(default_collator(), [])
  assert_true(index.is_empty())
  assert_eq(index.length(), 0)
  assert_eq(index.lower_bound("a"), 0)
  assert_eq(index.upper_bound("a"), 0)
  assert_eq(index.equal_range("a"), [])
  assert_eq(index.range("a", "z"), [])
  assert_eq(index.count_equal("a"), 0)
  assert_false(index.contains("a"))
}

///|
test "collation index returns half-open ranges" {
  let index = CollationIndex::new(default_collator(), [
    "foxtrot", "alpha", "echo", "bravo", "delta", "charlie",
  ])
  assert_eq(index.range("bravo", "foxtrot"), [
    "bravo", "charlie", "delta", "echo",
  ])
  assert_eq(index.range("echo", "echo"), [])
  assert_eq(index.range("foxtrot", "bravo"), [])
}

///|
test "collation index range and counts follow configured equality" {
  let primary = default_collator().with_strength(Strength::Primary)
  let index = CollationIndex::new(primary, [
    "Zulu", "f", "É", "e", "E", "apple",
  ])
  assert_eq(index.count_equal("e"), 3)
  assert_eq(index.range("e", "g"), ["É", "e", "E", "f"])
  let numeric = CollationIndex::new(default_collator().with_numeric(true), [
    "file20", "file3", "file10", "file2",
  ])
  assert_eq(numeric.range("file3", "file20"), ["file3", "file10"])
}

///|
test "collation index range honors shifted punctuation" {
  let shifted = default_collator()
    .with_strength(Strength::Primary)
    .with_alternate(AlternateHandling::Shifted)
  let index = CollationIndex::new(shifted, ["co-op", "coop", "delta"])
  assert_eq(index.count_equal("coop"), 2)
  assert_eq(index.range("coop", "delta"), ["co-op", "coop"])
}
