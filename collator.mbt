///|
fn codepoints_of(text : String) -> Array[Int] {
  text.to_array().map(char => char.to_int())
}

///|
fn reverse_copy(values : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for index = values.length() - 1; index >= 0; index = index - 1 {
    result.push(values[index])
  }
  result
}

///|
fn apply_case_first(weight : Int, policy : CaseFirst) -> Int {
  match policy {
    CaseOff | LowerFirst => weight
    UpperFirst =>
      if weight >= 8 && weight <= 31 {
        weight - 7
      } else {
        weight + 7
      }
  }
}

///|
fn is_ascii_digit(codepoint : Int) -> Bool {
  codepoint >= 0x30 && codepoint <= 0x39
}

///|
fn numeric_match(codepoints : Array[Int], at : Int) -> DucetMatch {
  let mut end = at
  while end < codepoints.length() && is_ascii_digit(codepoints[end]) {
    end = end + 1
  }
  let mut significant = at
  while significant + 1 < end && codepoints[significant] == 0x30 {
    significant = significant + 1
  }
  let elements : Array[CollationElement] = [
    CollationElement::new(primary=0x21E6, secondary=0x20, tertiary=0x02),
    CollationElement::new(
      primary=0x200 + end - significant,
      secondary=0,
      tertiary=0,
    ),
  ]
  for index = significant; index < end; index = index + 1 {
    elements.push(
      CollationElement::new(
        primary=0x300 + codepoints[index] - 0x30,
        secondary=0,
        tertiary=0,
      ),
    )
  }
  let input : Array[Int] = []
  for index = at; index < end; index = index + 1 {
    input.push(codepoints[index])
  }
  { consumed: end - at, input, elements, source: "numeric sequence", }
}

///|
fn build_key(
  collator : Collator,
  elements : Array[CollationElement],
  identical : Array[Int],
) -> SortKey {
  let primary : Array[Int] = []
  let secondary : Array[Int] = []
  let tertiary : Array[Int] = []
  let quaternary : Array[Int] = []
  let mut in_shifted_run = false
  for element in elements {
    if collator.alternate_handling() == Shifted &&
      element.is_variable() &&
      element.primary() != 0 {
      quaternary.push(element.primary())
      in_shifted_run = true
    } else if collator.alternate_handling() == Shifted &&
      in_shifted_run &&
      element.primary() == 0 {
      ()
    } else {
      if element.primary() != 0 {
        primary.push(element.primary())
        in_shifted_run = false
      }
      if element.secondary() != 0 {
        secondary.push(element.secondary())
      }
      if element.tertiary() != 0 {
        tertiary.push(
          apply_case_first(element.tertiary(), collator.case_first()),
        )
      }
      if collator.alternate_handling() == Shifted && element.primary() != 0 {
        quaternary.push(0xFFFF)
      } else if element.quaternary() != 0 {
        quaternary.push(element.quaternary())
      }
    }
  }
  {
    primary,
    secondary: if collator.is_backwards_secondary() {
      reverse_copy(secondary)
    } else {
      secondary
    },
    tertiary,
    quaternary,
    identical,
  }
}

///|
fn Collator::analyze(self : Collator, text : String) -> CollationTrace {
  let normalized = nfd_unicode_17(text)
  let codepoints = codepoints_of(normalized)
  let steps : Array[TraceStep] = []
  let elements : Array[CollationElement] = []
  let mut at = 0
  while at < codepoints.length() {
    let found = if self.is_numeric() && is_ascii_digit(codepoints[at]) {
      numeric_match(codepoints, at)
    } else {
      lookup_at(codepoints, at)
    }
    for element in found.elements {
      elements.push(element)
    }
    steps.push({
      input: found.input,
      elements: found.elements,
      source: found.source,
    })
    at = at + found.consumed
  }
  {
    original: text,
    normalized,
    steps,
    key: build_key(self, elements, codepoints),
  }
}

///|
/// Produce a stable multi-level UCA sort key for `text`.
pub fn Collator::sort_key(self : Collator, text : String) -> SortKey {
  self.analyze(text).sort_key()
}

///|
/// Explain normalization, DUCET mappings, and the resulting sort key.
pub fn Collator::explain(self : Collator, text : String) -> CollationTrace {
  self.analyze(text)
}

///|
fn compare_level(left : Array[Int], right : Array[Int]) -> Ordering {
  let shared = if left.length() < right.length() {
    left.length()
  } else {
    right.length()
  }
  for index = 0; index < shared; index = index + 1 {
    if left[index] < right[index] {
      return Less
    } else if left[index] > right[index] {
      return Greater
    }
  }
  if left.length() < right.length() {
    Less
  } else if left.length() > right.length() {
    Greater
  } else {
    Equal
  }
}

///|
fn strength_rank(strength : Strength) -> Int {
  match strength {
    Primary => 1
    Secondary => 2
    Tertiary => 3
    Quaternary => 4
    Identical => 5
  }
}

///|
/// Compare two strings according to this collator's configuration.
pub fn Collator::compare(
  self : Collator,
  left : String,
  right : String,
) -> Ordering {
  let left_key = self.sort_key(left)
  let right_key = self.sort_key(right)
  let primary = compare_level(left_key.primary, right_key.primary)
  if primary != Equal || strength_rank(self.strength()) == 1 {
    return primary
  }
  let secondary = compare_level(left_key.secondary, right_key.secondary)
  if secondary != Equal || strength_rank(self.strength()) == 2 {
    return secondary
  }
  let tertiary = compare_level(left_key.tertiary, right_key.tertiary)
  if tertiary != Equal || strength_rank(self.strength()) == 3 {
    return tertiary
  }
  let quaternary = compare_level(left_key.quaternary, right_key.quaternary)
  if quaternary != Equal || strength_rank(self.strength()) == 4 {
    return quaternary
  }
  compare_level(left_key.identical, right_key.identical)
}

///|
/// Return true when `left` sorts before `right`.
pub fn Collator::less(self : Collator, left : String, right : String) -> Bool {
  self.compare(left, right) == Less
}
