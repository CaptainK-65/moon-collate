///|
/// Comparison result returned by a collator.
pub(all) enum Ordering {
  Less
  Equal
  Greater
} derive(Debug, Eq, ToJson)

///|
/// Convert an ordering result to a stable textual representation.
pub fn Ordering::to_string(self : Ordering) -> String {
  match self {
    Less => "Less"
    Equal => "Equal"
    Greater => "Greater"
  }
}

///|
/// The strongest collation level considered by a comparison.
pub(all) enum Strength {
  Primary
  Secondary
  Tertiary
  Quaternary
  Identical
} derive(Debug, Eq, ToJson)

///|
/// Treatment of variable collation elements such as spaces and punctuation.
pub(all) enum AlternateHandling {
  NonIgnorable
  Shifted
} derive(Debug, Eq, ToJson)

///|
/// Optional case ordering applied at tertiary strength.
pub(all) enum CaseFirst {
  CaseOff
  UpperFirst
  LowerFirst
} derive(Debug, Eq, ToJson)

///|
/// One collation element as defined by UTS #10.
pub(all) struct CollationElement {
  primary : Int
  secondary : Int
  tertiary : Int
  quaternary : Int
  variable : Bool
} derive(Debug, Eq, ToJson)

///|
/// Create a collation element with explicit level weights.
pub fn CollationElement::new(
  primary~ : Int,
  secondary~ : Int,
  tertiary~ : Int,
  quaternary? : Int = 0,
  variable? : Bool = false,
) -> CollationElement {
  { primary, secondary, tertiary, quaternary, variable, }
}

///|
pub fn CollationElement::primary(self : CollationElement) -> Int {
  self.primary
}

///|
pub fn CollationElement::secondary(self : CollationElement) -> Int {
  self.secondary
}

///|
pub fn CollationElement::tertiary(self : CollationElement) -> Int {
  self.tertiary
}

///|
pub fn CollationElement::quaternary(self : CollationElement) -> Int {
  self.quaternary
}

///|
pub fn CollationElement::is_variable(self : CollationElement) -> Bool {
  self.variable
}

///|
/// A stable, lexicographically comparable collation key.
pub(all) struct SortKey {
  primary : Array[Int]
  secondary : Array[Int]
  tertiary : Array[Int]
  quaternary : Array[Int]
  identical : Array[Int]
} derive(Debug, Eq, ToJson)

///|
pub fn SortKey::primary(self : SortKey) -> Array[Int] {
  self.primary.copy()
}

///|
pub fn SortKey::secondary(self : SortKey) -> Array[Int] {
  self.secondary.copy()
}

///|
pub fn SortKey::tertiary(self : SortKey) -> Array[Int] {
  self.tertiary.copy()
}

///|
pub fn SortKey::quaternary(self : SortKey) -> Array[Int] {
  self.quaternary.copy()
}

///|
pub fn SortKey::identical(self : SortKey) -> Array[Int] {
  self.identical.copy()
}

///|
/// A single mapping decision recorded by the explanation engine.
pub(all) struct TraceStep {
  input : Array[Int]
  elements : Array[CollationElement]
  source : String
} derive(Debug, Eq, ToJson)

///|
/// Full diagnostic trace for one input string.
pub(all) struct CollationTrace {
  original : String
  normalized : String
  steps : Array[TraceStep]
  key : SortKey
} derive(Debug, Eq, ToJson)

///|
pub fn CollationTrace::original(self : CollationTrace) -> String {
  self.original
}

///|
pub fn CollationTrace::normalized(self : CollationTrace) -> String {
  self.normalized
}

///|
pub fn CollationTrace::steps(self : CollationTrace) -> Array[TraceStep] {
  self.steps.copy()
}

///|
pub fn CollationTrace::sort_key(self : CollationTrace) -> SortKey {
  self.key
}

///|
pub fn TraceStep::input(self : TraceStep) -> Array[Int] {
  self.input.copy()
}

///|
pub fn TraceStep::elements(self : TraceStep) -> Array[CollationElement] {
  self.elements.copy()
}

///|
pub fn TraceStep::source(self : TraceStep) -> String {
  self.source
}
