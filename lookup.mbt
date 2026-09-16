///|
/// Internal result of a DUCET table lookup.
priv struct DucetMatch {
  consumed : Int
  input : Array[Int]
  elements : Array[CollationElement]
  source : String
}

///|
fn make_single_elements(index : Int) -> Array[CollationElement] {
  let result : Array[CollationElement] = []
  let start = ducet_single_element_starts[index]
  let count = ducet_single_element_lengths[index]
  for offset = 0; offset < count; offset = offset + 1 {
    let position = start + offset
    result.push(
      CollationElement::new(
        primary=ducet_single_primary[position],
        secondary=ducet_single_secondary[position],
        tertiary=ducet_single_tertiary[position],
        variable=ducet_single_flags[position] == 1,
      ),
    )
  }
  result
}

///|
fn find_single(codepoint : Int) -> Int {
  let mut low = 0
  let mut high = ducet_single_keys.length() - 1
  while low <= high {
    let middle = low + (high - low) / 2
    let key = ducet_single_keys[middle]
    if key == codepoint {
      return middle
    } else if key < codepoint {
      low = middle + 1
    } else {
      high = middle - 1
    }
  }
  -1
}

///|
fn contraction_matches(
  codepoints : Array[Int],
  input_at : Int,
  mapping_at : Int,
) -> Bool {
  let length = ducet_contraction_key_lengths[mapping_at]
  if input_at + length > codepoints.length() {
    return false
  }
  let start = ducet_contraction_key_starts[mapping_at]
  for offset = 0; offset < length; offset = offset + 1 {
    if codepoints[input_at + offset] != ducet_contraction_keys[start + offset] {
      return false
    }
  }
  true
}

///|
fn make_contraction_elements(index : Int) -> Array[CollationElement] {
  let result : Array[CollationElement] = []
  let start = ducet_contraction_element_starts[index]
  let count = ducet_contraction_element_lengths[index]
  for offset = 0; offset < count; offset = offset + 1 {
    let position = start + offset
    result.push(
      CollationElement::new(
        primary=ducet_contraction_primary[position],
        secondary=ducet_contraction_secondary[position],
        tertiary=ducet_contraction_tertiary[position],
        variable=ducet_contraction_flags[position] == 1,
      ),
    )
  }
  result
}

///|
fn find_contraction(codepoints : Array[Int], at : Int) -> DucetMatch? {
  let first = codepoints[at]
  let mut best = -1
  let mut best_length = 0
  for index = 0
      index < ducet_contraction_key_lengths.length()
      index = index + 1 {
    let start = ducet_contraction_key_starts[index]
    let candidate_first = ducet_contraction_keys[start]
    if candidate_first == first &&
      ducet_contraction_key_lengths[index] > best_length &&
      contraction_matches(codepoints, at, index) {
      best = index
      best_length = ducet_contraction_key_lengths[index]
    }
  }
  if best < 0 {
    None
  } else {
    let input : Array[Int] = []
    for offset = 0; offset < best_length; offset = offset + 1 {
      input.push(codepoints[at + offset])
    }
    Some({
      consumed: best_length,
      input,
      elements: make_contraction_elements(best),
      source: "DUCET contraction",
    })
  }
}

///|
fn special_implicit_lead(codepoint : Int) -> Int? {
  for index = 0; index < ducet_implicit_first.length(); index = index + 1 {
    if codepoint >= ducet_implicit_first[index] &&
      codepoint <= ducet_implicit_last[index] {
      return Some(ducet_implicit_lead[index])
    }
  }
  None
}

///|
fn is_unified_ideograph(codepoint : Int) -> Bool {
  (codepoint >= 0x3400 && codepoint <= 0x4DBF) ||
  (codepoint >= 0x4E00 && codepoint <= 0x9FFF) ||
  (codepoint >= 0x20000 && codepoint <= 0x323AF)
}

///|
fn implicit_elements(codepoint : Int) -> Array[CollationElement] {
  let lead_base = match special_implicit_lead(codepoint) {
    Some(lead) => lead
    None => if is_unified_ideograph(codepoint) { 0xFB40 } else { 0xFBC0 }
  }
  let lead = lead_base + codepoint / 0x8000
  let trail = 0x8000 + codepoint % 0x8000
  [
    CollationElement::new(primary=lead, secondary=0x20, tertiary=0x02),
    CollationElement::new(primary=trail, secondary=0, tertiary=0),
  ]
}

///|
fn lookup_at(codepoints : Array[Int], at : Int) -> DucetMatch {
  match find_contraction(codepoints, at) {
    Some(found) => found
    None => {
      let codepoint = codepoints[at]
      let single = find_single(codepoint)
      if single >= 0 {
        {
          consumed: 1,
          input: [codepoint],
          elements: make_single_elements(single),
          source: "DUCET singleton",
        }
      } else {
        {
          consumed: 1,
          input: [codepoint],
          elements: implicit_elements(codepoint),
          source: "UCA implicit weight",
        }
      }
    }
  }
}
