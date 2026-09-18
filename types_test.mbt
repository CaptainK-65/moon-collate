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

///|
test "public key and trace accessors expose defensive values" {
  let collator = default_collator()
  let key = collator.sort_key("é")
  assert_true(key.primary().length() > 0)
  assert_true(key.secondary().length() > 0)
  assert_true(key.tertiary().length() > 0)
  assert_true(key.identical().length() > 0)
  let shifted = collator
    .with_alternate(AlternateHandling::Shifted)
    .sort_key("-")
  assert_true(shifted.quaternary().length() > 0)
  let trace = collator.explain("é")
  assert_eq(trace.sort_key(), key)
  let steps = trace.steps()
  assert_true(steps[0].input().length() > 0)
  assert_true(steps[0].elements().length() > 0)
  assert_true(steps[0].source().length() > 0)
}

///|
test "collation element accessors preserve explicit weights" {
  let element = CollationElement::new(
    primary=1,
    secondary=2,
    tertiary=3,
    quaternary=4,
    variable=true,
  )
  assert_eq(element.primary(), 1)
  assert_eq(element.secondary(), 2)
  assert_eq(element.tertiary(), 3)
  assert_eq(element.quaternary(), 4)
  assert_true(element.is_variable())
}
