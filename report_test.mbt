///|
test "detailed report identifies a primary difference" {
  let report = default_collator().compare_detailed("apple", "banana")
  assert_eq(report.ordering(), Ordering::Less)
  guard report.difference() is Some(difference) else {
    fail("expected a decisive difference")
  }
  assert_eq(difference.level(), DifferenceLevel::PrimaryLevel)
  assert_eq(difference.index(), 0)
  assert_true(difference.left_weight() < difference.right_weight())
  assert_eq(report.left_key(), default_collator().sort_key("apple"))
  assert_eq(report.right_key(), default_collator().sort_key("banana"))
}

///|
test "detailed report identifies an accent difference" {
  let report = default_collator()
    .with_strength(Strength::Secondary)
    .compare_detailed("e", "é")
  guard report.difference() is Some(difference) else {
    fail("expected an accent difference")
  }
  assert_eq(difference.level(), DifferenceLevel::SecondaryLevel)
  assert_eq(difference.level().to_string(), "secondary")
}

///|
test "detailed report suppresses differences below strength" {
  let report = default_collator()
    .with_strength(Strength::Primary)
    .compare_detailed("resume", "résumé")
  assert_eq(report.ordering(), Ordering::Equal)
  assert_eq(report.difference(), None)
}

///|
test "equivalent follows configured strength" {
  assert_true(
    default_collator().with_strength(Strength::Primary).equivalent("A", "á"),
  )
  assert_false(default_collator().equivalent("A", "á"))
}

///|
test "flatten includes only requested levels" {
  let key = default_collator().sort_key("a")
  let primary = key.flatten(Strength::Primary)
  let tertiary = key.flatten(Strength::Tertiary)
  assert_eq(primary[primary.length() - 1], 0)
  assert_eq(tertiary[tertiary.length() - 1], 0)
  assert_true(tertiary.length() > primary.length())
  let quaternary = key.flatten(Strength::Quaternary)
  let identical = key.flatten(Strength::Identical)
  assert_true(quaternary.length() > tertiary.length())
  assert_true(identical.length() > quaternary.length())
}

///|
test "detailed report covers shifted quaternary and identical equality" {
  let shifted = default_collator()
    .with_alternate(AlternateHandling::Shifted)
    .with_strength(Strength::Quaternary)
  let report = shifted.compare_detailed("coop", "co-op")
  guard report.difference() is Some(difference) else {
    fail("expected a quaternary difference")
  }
  assert_eq(difference.level(), DifferenceLevel::QuaternaryLevel)
  let quaternary_equal = shifted.compare_detailed("same", "same")
  assert_eq(quaternary_equal.ordering(), Ordering::Equal)
  assert_eq(quaternary_equal.difference(), None)
  let identical = default_collator()
    .with_strength(Strength::Identical)
    .compare_detailed("same", "same")
  assert_eq(identical.ordering(), Ordering::Equal)
  assert_eq(identical.difference(), None)
}

///|
test "hex key uses fixed-width uppercase words and separators" {
  let key = default_collator().sort_key("a")
  let encoded = key.to_hex(Strength::Tertiary)
  assert_true(encoded.contains("0000"))
  assert_true(encoded.length() >= 24)
}

///|
test "difference level names are stable" {
  assert_eq(DifferenceLevel::PrimaryLevel.to_string(), "primary")
  assert_eq(DifferenceLevel::SecondaryLevel.to_string(), "secondary")
  assert_eq(DifferenceLevel::TertiaryLevel.to_string(), "tertiary")
  assert_eq(DifferenceLevel::QuaternaryLevel.to_string(), "quaternary")
  assert_eq(DifferenceLevel::IdenticalLevel.to_string(), "identical")
}
