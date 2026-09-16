///|
/// The first sort-key level that decides a comparison.
pub(all) enum DifferenceLevel {
  PrimaryLevel
  SecondaryLevel
  TertiaryLevel
  QuaternaryLevel
  IdenticalLevel
} derive(Debug, Eq, ToJson)

///|
pub fn DifferenceLevel::to_string(self : DifferenceLevel) -> String {
  match self {
    PrimaryLevel => "primary"
    SecondaryLevel => "secondary"
    TertiaryLevel => "tertiary"
    QuaternaryLevel => "quaternary"
    IdenticalLevel => "identical"
  }
}

///|
/// Location and weights of the first decisive sort-key difference.
pub(all) struct ComparisonDifference {
  level : DifferenceLevel
  index : Int
  left_weight : Int
  right_weight : Int
} derive(Debug, Eq, ToJson)

///|
pub fn ComparisonDifference::level(
  self : ComparisonDifference,
) -> DifferenceLevel {
  self.level
}

///|
pub fn ComparisonDifference::index(self : ComparisonDifference) -> Int {
  self.index
}

///|
pub fn ComparisonDifference::left_weight(self : ComparisonDifference) -> Int {
  self.left_weight
}

///|
pub fn ComparisonDifference::right_weight(self : ComparisonDifference) -> Int {
  self.right_weight
}

///|
/// A comparison result with both keys and the first decisive difference.
pub(all) struct ComparisonReport {
  ordering : Ordering
  difference : ComparisonDifference?
  left_key : SortKey
  right_key : SortKey
} derive(Debug, Eq, ToJson)

///|
pub fn ComparisonReport::ordering(self : ComparisonReport) -> Ordering {
  self.ordering
}

///|
pub fn ComparisonReport::difference(
  self : ComparisonReport,
) -> ComparisonDifference? {
  self.difference
}

///|
pub fn ComparisonReport::left_key(self : ComparisonReport) -> SortKey {
  self.left_key
}

///|
pub fn ComparisonReport::right_key(self : ComparisonReport) -> SortKey {
  self.right_key
}

///|
fn first_weight_difference(
  level : DifferenceLevel,
  left : Array[Int],
  right : Array[Int],
) -> ComparisonDifference? {
  let shared = if left.length() < right.length() {
    left.length()
  } else {
    right.length()
  }
  for index = 0; index < shared; index = index + 1 {
    if left[index] != right[index] {
      return Some({
        level,
        index,
        left_weight: left[index],
        right_weight: right[index],
      })
    }
  }
  if left.length() != right.length() {
    Some({
      level,
      index: shared,
      left_weight: if shared < left.length() {
        left[shared]
      } else {
        0
      },
      right_weight: if shared < right.length() {
        right[shared]
      } else {
        0
      },
    })
  } else {
    None
  }
}

///|
fn decisive_difference(
  strength : Strength,
  left : SortKey,
  right : SortKey,
) -> ComparisonDifference? {
  match first_weight_difference(PrimaryLevel, left.primary, right.primary) {
    Some(value) => return Some(value)
    None => ()
  }
  if strength_rank(strength) < 2 {
    return None
  }
  match
    first_weight_difference(SecondaryLevel, left.secondary, right.secondary) {
    Some(value) => return Some(value)
    None => ()
  }
  if strength_rank(strength) < 3 {
    return None
  }
  match first_weight_difference(TertiaryLevel, left.tertiary, right.tertiary) {
    Some(value) => return Some(value)
    None => ()
  }
  if strength_rank(strength) < 4 {
    return None
  }
  match
    first_weight_difference(QuaternaryLevel, left.quaternary, right.quaternary) {
    Some(value) => return Some(value)
    None => ()
  }
  if strength_rank(strength) < 5 {
    return None
  }
  first_weight_difference(IdenticalLevel, left.identical, right.identical)
}

///|
/// Compare strings and retain enough structured evidence for diagnostics.
pub fn Collator::compare_detailed(
  self : Collator,
  left : String,
  right : String,
) -> ComparisonReport {
  let left_key = self.sort_key(left)
  let right_key = self.sort_key(right)
  {
    ordering: self.compare_keys(left_key, right_key),
    difference: decisive_difference(self.strength(), left_key, right_key),
    left_key,
    right_key,
  }
}

///|
/// Return true when two strings are equal at the configured strength.
pub fn Collator::equivalent(
  self : Collator,
  left : String,
  right : String,
) -> Bool {
  self.compare(left, right) == Equal
}

///|
fn append_level(target : Array[Int], source : Array[Int]) -> Unit {
  for weight in source {
    target.push(weight)
  }
  target.push(0)
}

///|
/// Flatten a structured key through `strength`, separating levels with zero.
/// All emitted UCA weights are non-zero, so separators remain unambiguous.
pub fn SortKey::flatten(self : SortKey, strength : Strength) -> Array[Int] {
  let result : Array[Int] = []
  append_level(result, self.primary)
  if strength_rank(strength) >= 2 {
    append_level(result, self.secondary)
  }
  if strength_rank(strength) >= 3 {
    append_level(result, self.tertiary)
  }
  if strength_rank(strength) >= 4 {
    append_level(result, self.quaternary)
  }
  if strength_rank(strength) >= 5 {
    append_level(result, self.identical)
  }
  result
}

///|
fn hex_digit(value : Int) -> Char {
  if value < 10 {
    (0x30 + value).to_char().unwrap()
  } else {
    (0x41 + value - 10).to_char().unwrap()
  }
}

///|
fn weight_hex(value : Int) -> String {
  if value == 0 {
    return "0000"
  }
  let digits : Array[Char] = []
  let mut remaining = value
  while remaining > 0 {
    digits.push(hex_digit(remaining % 16))
    remaining = remaining / 16
  }
  while digits.length() < 4 {
    digits.push('0')
  }
  let ordered : Array[Char] = []
  for index = digits.length() - 1; index >= 0; index = index - 1 {
    ordered.push(digits[index])
  }
  String::from_array(ordered)
}

///|
/// Format a flattened key as uppercase hexadecimal words.
pub fn SortKey::to_hex(self : SortKey, strength : Strength) -> String {
  let out = StringBuilder()
  for index, weight in self.flatten(strength) {
    if index > 0 {
      out.write_char(' ')
    }
    out.write_string(weight_hex(weight))
  }
  out.to_string()
}
