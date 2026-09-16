///|
/// Immutable configuration and entry point for Unicode collation.
pub(all) struct Collator {
  strength : Strength
  alternate : AlternateHandling
  case_first : CaseFirst
  backwards_secondary : Bool
  numeric : Bool
}

///|
/// Construct a collator. Defaults match the root DUCET profile.
pub fn Collator::new(
  strength? : Strength = Tertiary,
  alternate? : AlternateHandling = NonIgnorable,
  case_first? : CaseFirst = CaseOff,
  backwards_secondary? : Bool = false,
  numeric? : Bool = false,
) -> Collator {
  { strength, alternate, case_first, backwards_secondary, numeric, }
}

///|
/// Return the default Unicode collator.
pub fn default_collator() -> Collator {
  Collator::new()
}

///|
pub fn Collator::strength(self : Collator) -> Strength {
  self.strength
}

///|
pub fn Collator::alternate_handling(self : Collator) -> AlternateHandling {
  self.alternate
}

///|
pub fn Collator::case_first(self : Collator) -> CaseFirst {
  self.case_first
}

///|
pub fn Collator::is_backwards_secondary(self : Collator) -> Bool {
  self.backwards_secondary
}

///|
pub fn Collator::is_numeric(self : Collator) -> Bool {
  self.numeric
}

///|
/// Create a copy with a different comparison strength.
pub fn Collator::with_strength(
  self : Collator,
  strength : Strength,
) -> Collator {
  { ..self, strength, }
}

///|
/// Create a copy with different variable-weight handling.
pub fn Collator::with_alternate(
  self : Collator,
  alternate : AlternateHandling,
) -> Collator {
  { ..self, alternate, }
}

///|
/// Create a copy with a different case-first policy.
pub fn Collator::with_case_first(
  self : Collator,
  case_first : CaseFirst,
) -> Collator {
  { ..self, case_first, }
}

///|
/// Create a copy with backwards-secondary comparison enabled or disabled.
pub fn Collator::with_backwards_secondary(
  self : Collator,
  enabled : Bool,
) -> Collator {
  { ..self, backwards_secondary: enabled, }
}

///|
/// Create a copy with numeric collation enabled or disabled.
pub fn Collator::with_numeric(self : Collator, enabled : Bool) -> Collator {
  { ..self, numeric: enabled, }
}
