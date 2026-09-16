///|
test "ordering has a stable representation" {
  inspect(Ordering::Less.to_string(), content="Less")
  inspect(Ordering::Equal.to_string(), content="Equal")
  inspect(Ordering::Greater.to_string(), content="Greater")
}

///|
test "default collator exposes the root profile" {
  let collator = default_collator()
  assert_eq(collator.strength(), Strength::Tertiary)
  assert_eq(collator.alternate_handling(), AlternateHandling::NonIgnorable)
  assert_eq(collator.case_first(), CaseFirst::CaseOff)
  assert_false(collator.is_backwards_secondary())
  assert_false(collator.is_numeric())
}

///|
test "collator builders leave the original immutable" {
  let original = default_collator()
  let configured = original
    .with_strength(Strength::Primary)
    .with_alternate(AlternateHandling::Shifted)
    .with_case_first(CaseFirst::UpperFirst)
    .with_backwards_secondary(true)
    .with_numeric(true)
  assert_eq(original.strength(), Strength::Tertiary)
  assert_eq(configured.strength(), Strength::Primary)
  assert_eq(configured.alternate_handling(), AlternateHandling::Shifted)
  assert_eq(configured.case_first(), CaseFirst::UpperFirst)
  assert_true(configured.is_backwards_secondary())
  assert_true(configured.is_numeric())
}
