///|
test "CLI parses strengths and rejects invalid values" {
  assert_eq(parse_strength("primary"), Some(@collate.Strength::Primary))
  assert_eq(parse_strength("secondary"), Some(@collate.Strength::Secondary))
  assert_eq(parse_strength("tertiary"), Some(@collate.Strength::Tertiary))
  assert_eq(parse_strength("quaternary"), Some(@collate.Strength::Quaternary))
  assert_eq(parse_strength("identical"), Some(@collate.Strength::Identical))
  assert_eq(parse_strength("invalid"), None)
}

///|
test "CLI composes options and preserves operands" {
  let parsed = parse_options(
    [
      "moon-collate", "compare", "--strength", "identical", "--shifted", "--numeric",
      "--upper-first", "--lower-first", "--backwards-secondary", "left", "right",
    ],
    2,
  )
  guard parsed is Some((collator, operands)) else {
    fail("expected valid CLI options")
  }
  assert_eq(collator.strength(), @collate.Strength::Identical)
  assert_eq(collator.alternate_handling(), @collate.AlternateHandling::Shifted)
  assert_eq(collator.case_first(), @collate.CaseFirst::LowerFirst)
  assert_true(collator.is_backwards_secondary())
  assert_true(collator.is_numeric())
  assert_eq(operands, ["left", "right"])
}

///|
test "CLI rejects incomplete strength options" {
  assert_true(parse_options(["moon-collate", "key", "--strength"], 2) is None)
  assert_true(
    parse_options(["moon-collate", "key", "--strength", "invalid"], 2) is None,
  )
}

///|
test "CLI helpers cover ordering and operand validation" {
  assert_true(usage().contains("Unicode 17.0.0"))
  assert_eq(ordering_number(@collate.Ordering::Less), -1)
  assert_eq(ordering_number(@collate.Ordering::Equal), 0)
  assert_eq(ordering_number(@collate.Ordering::Greater), 1)
  let collator = @collate.default_collator()
  assert_false(command_compare(collator, ["only-one"]))
  assert_false(command_key(collator, []))
  assert_false(command_explain(collator, []))
  assert_false(command_sort(collator, []))
  assert_true(command_compare(collator, ["a", "b"]))
  assert_true(command_key(collator, ["a"]))
  assert_true(command_explain(collator, ["é"]))
  assert_true(command_sort(collator, ["b", "a"]))
}
