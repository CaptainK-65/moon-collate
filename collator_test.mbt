///|
test "root DUCET orders basic Latin text" {
  let collator = default_collator()
  assert_eq(collator.compare("alpha", "beta"), Ordering::Less)
  assert_eq(collator.compare("beta", "alpha"), Ordering::Greater)
  assert_eq(collator.compare("same", "same"), Ordering::Equal)
}

///|
test "canonical equivalents produce the same key" {
  let collator = default_collator()
  let composed = "caf\u{00E9}"
  let decomposed = "cafe\u{0301}"
  assert_eq(collator.sort_key(composed), collator.sort_key(decomposed))
  assert_eq(collator.compare(composed, decomposed), Ordering::Equal)
}

///|
test "strength controls accent sensitivity" {
  let primary = default_collator().with_strength(Strength::Primary)
  let secondary = primary.with_strength(Strength::Secondary)
  assert_eq(primary.compare("resume", "r\u{00E9}sum\u{00E9}"), Ordering::Equal)
  assert_eq(secondary.compare("resume", "r\u{00E9}sum\u{00E9}"), Ordering::Less)
}

///|
test "numeric mode compares digit runs by value" {
  let lexical = default_collator()
  let numeric = lexical.with_numeric(true)
  assert_eq(lexical.compare("file2", "file10"), Ordering::Greater)
  assert_eq(numeric.compare("file2", "file10"), Ordering::Less)
}

///|
test "shifted mode ignores punctuation at primary strength" {
  let collator = default_collator()
    .with_strength(Strength::Primary)
    .with_alternate(AlternateHandling::Shifted)
  assert_eq(collator.compare("coop", "co-op"), Ordering::Equal)
}

///|
test "explanation exposes normalization and mappings" {
  let trace = default_collator().explain("\u{00E9}")
  assert_eq(trace.original(), "\u{00E9}")
  assert_eq(trace.normalized(), "e\u{0301}")
  assert_true(trace.steps().length() > 0)
}

///|
test "case-first and backwards-secondary options affect keys" {
  let upper = default_collator().with_case_first(CaseFirst::UpperFirst)
  let lower = default_collator().with_case_first(CaseFirst::LowerFirst)
  assert_eq(upper.compare("A", "a"), Ordering::Less)
  assert_eq(lower.compare("A", "a"), Ordering::Greater)
  let forward_key = default_collator().sort_key("éà").secondary()
  let backward_key = default_collator()
    .with_backwards_secondary(true)
    .sort_key("éà")
    .secondary()
  assert_eq(backward_key[0], forward_key[forward_key.length() - 1])
}

///|
test "quaternary and identical strengths reach their decisive levels" {
  let quaternary = default_collator()
    .with_alternate(AlternateHandling::Shifted)
    .with_strength(Strength::Quaternary)
  assert_true(quaternary.compare("coop", "co-op") != Ordering::Equal)
  let identical = default_collator().with_strength(Strength::Identical)
  assert_eq(identical.compare("same", "same"), Ordering::Equal)
  assert_true(identical.less("alpha", "beta"))
  assert_false(identical.less("beta", "alpha"))
}
