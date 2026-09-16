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
fn combining_class(codepoint : Int) -> Int {
  canonical_combining_class(codepoint)
}

///|
fn contraction_prefix_exists(mapping_at : Int, prefix_length : Int) -> Bool {
  if prefix_length <= 1 {
    return true
  }
  let source_start = ducet_contraction_key_starts[mapping_at]
  for candidate = 0
      candidate < ducet_contraction_key_lengths.length()
      candidate = candidate + 1 {
    if ducet_contraction_key_lengths[candidate] == prefix_length {
      let candidate_start = ducet_contraction_key_starts[candidate]
      let mut equal = true
      for offset = 0; offset < prefix_length; offset = offset + 1 {
        if ducet_contraction_keys[source_start + offset] !=
          ducet_contraction_keys[candidate_start + offset] {
          equal = false
          break
        }
      }
      if equal {
        return true
      }
    }
  }
  false
}

///|
fn match_contraction(
  codepoints : Array[Int],
  input_at : Int,
  mapping_at : Int,
) -> (Int, Array[Int])? {
  let length = ducet_contraction_key_lengths[mapping_at]
  let start = ducet_contraction_key_starts[mapping_at]
  if codepoints[input_at] != ducet_contraction_keys[start] {
    return None
  }
  let skipped : Array[Int] = []
  let mut cursor = input_at + 1
  for key_offset = 1; key_offset < length; key_offset = key_offset + 1 {
    let expected = ducet_contraction_keys[start + key_offset]
    if cursor >= codepoints.length() {
      return None
    }
    if codepoints[cursor] == expected {
      cursor = cursor + 1
      continue
    }
    let expected_ccc = combining_class(expected)
    if expected_ccc == 0 {
      return None
    }
    while cursor < codepoints.length() &&
          codepoints[cursor] != expected &&
          combining_class(codepoints[cursor]) > 0 &&
          combining_class(codepoints[cursor]) < expected_ccc {
      skipped.push(codepoints[cursor])
      cursor = cursor + 1
    }
    if cursor >= codepoints.length() || codepoints[cursor] != expected {
      return None
    }
    cursor = cursor + 1
    if skipped.length() > 0 &&
      !contraction_prefix_exists(mapping_at, key_offset + 1) {
      return None
    }
  }
  Some((cursor - input_at, skipped))
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
  let mut best_consumed = 0
  let mut best_skipped : Array[Int] = []
  for index = 0
      index < ducet_contraction_key_lengths.length()
      index = index + 1 {
    let start = ducet_contraction_key_starts[index]
    let candidate_first = ducet_contraction_keys[start]
    if candidate_first == first &&
      ducet_contraction_key_lengths[index] > best_length {
      match match_contraction(codepoints, at, index) {
        Some((consumed, skipped)) => {
          best = index
          best_length = ducet_contraction_key_lengths[index]
          best_consumed = consumed
          best_skipped = skipped
        }
        None => ()
      }
    }
  }
  if best < 0 {
    None
  } else {
    let input : Array[Int] = []
    for offset = 0; offset < best_consumed; offset = offset + 1 {
      input.push(codepoints[at + offset])
    }
    let elements = make_contraction_elements(best)
    for skipped in best_skipped {
      let single = find_single(skipped)
      if single >= 0 {
        for element in make_single_elements(single) {
          elements.push(element)
        }
      } else {
        for element in implicit_elements(skipped) {
          elements.push(element)
        }
      }
    }
    Some({
      consumed: best_consumed,
      input,
      elements,
      source: if best_skipped.length() > 0 {
        "DUCET discontiguous contraction"
      } else {
        "DUCET contraction"
      },
    })
  }
}

///|
fn special_implicit_weights(codepoint : Int) -> (Int, Int)? {
  for index = 0; index < ducet_implicit_first.length(); index = index + 1 {
    if codepoint >= ducet_implicit_first[index] &&
      codepoint <= ducet_implicit_last[index] {
      let lead = ducet_implicit_lead[index]
      let base = match lead {
        0xFB00 => 0x17000
        0xFB01 => 0x18800
        0xFB02 => 0x1B170
        0xFB03 => 0x18B00
        _ => ducet_implicit_first[index]
      }
      return Some((lead, 0x8000 + codepoint - base))
    }
  }
  None
}

///|
fn is_core_han(codepoint : Int) -> Bool {
  codepoint >= 0x4E00 && codepoint <= 0x9FFF
}

///|
fn is_extension_han(codepoint : Int) -> Bool {
  (codepoint >= 0x3400 && codepoint <= 0x4DBF) ||
  (codepoint >= 0x20000 && codepoint <= 0x2A6DF) ||
  (codepoint >= 0x2A700 && codepoint <= 0x2B73F) ||
  (codepoint >= 0x2B740 && codepoint <= 0x2B81D) ||
  (codepoint >= 0x2B820 && codepoint <= 0x2CEAD) ||
  (codepoint >= 0x2CEB0 && codepoint <= 0x2EBE0) ||
  (codepoint >= 0x2EBF0 && codepoint <= 0x2EE5D) ||
  (codepoint >= 0x30000 && codepoint <= 0x3134A) ||
  (codepoint >= 0x31350 && codepoint <= 0x323AF) ||
  (codepoint >= 0x323B0 && codepoint <= 0x3347F)
}

///|
fn implicit_elements(codepoint : Int) -> Array[CollationElement] {
  let (lead, trail) = match special_implicit_weights(codepoint) {
    Some(weights) => weights
    None => {
      let base = if is_core_han(codepoint) {
        0xFB40
      } else if is_extension_han(codepoint) {
        0xFB80
      } else {
        0xFBC0
      }
      (base + codepoint / 0x8000, 0x8000 + codepoint % 0x8000)
    }
  }
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
