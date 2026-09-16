///|
fn normalization_record(codepoint : Int) -> Int {
  let mut low = 0
  let mut high = normalization_codepoints.length() - 1
  while low <= high {
    let middle = low + (high - low) / 2
    let current = normalization_codepoints[middle]
    if current == codepoint {
      return middle
    } else if current < codepoint {
      low = middle + 1
    } else {
      high = middle - 1
    }
  }
  -1
}

///|
fn canonical_combining_class(codepoint : Int) -> Int {
  let record = normalization_record(codepoint)
  if record < 0 {
    0
  } else {
    normalization_ccc[record]
  }
}

///|
fn decompose_hangul(codepoint : Int, output : Array[Int]) -> Bool {
  let s_base = 0xAC00
  let l_base = 0x1100
  let v_base = 0x1161
  let t_base = 0x11A7
  let v_count = 21
  let t_count = 28
  let n_count = v_count * t_count
  let s_count = 19 * n_count
  let s_index = codepoint - s_base
  if s_index < 0 || s_index >= s_count {
    return false
  }
  output.push(l_base + s_index / n_count)
  output.push(v_base + s_index % n_count / t_count)
  let t_index = s_index % t_count
  if t_index != 0 {
    output.push(t_base + t_index)
  }
  true
}

///|
fn canonical_decompose_into(codepoint : Int, output : Array[Int]) -> Unit {
  if decompose_hangul(codepoint, output) {
    return
  }
  let record = normalization_record(codepoint)
  if record < 0 || normalization_decomp_lengths[record] == 0 {
    output.push(codepoint)
    return
  }
  let start = normalization_decomp_starts[record]
  let length = normalization_decomp_lengths[record]
  for offset = 0; offset < length; offset = offset + 1 {
    canonical_decompose_into(
      normalization_decomp_values[start + offset],
      output,
    )
  }
}

///|
fn canonical_reorder(codepoints : Array[Int]) -> Unit {
  for index = 1; index < codepoints.length(); index = index + 1 {
    let current_ccc = canonical_combining_class(codepoints[index])
    if current_ccc != 0 {
      let value = codepoints[index]
      let mut insertion = index
      while insertion > 0 {
        let previous_ccc = canonical_combining_class(codepoints[insertion - 1])
        if previous_ccc == 0 || previous_ccc <= current_ccc {
          break
        }
        codepoints[insertion] = codepoints[insertion - 1]
        insertion = insertion - 1
      }
      codepoints[insertion] = value
    }
  }
}

///|
fn nfd_unicode_17(text : String) -> String {
  let decomposed : Array[Int] = []
  for char in text {
    canonical_decompose_into(char.to_int(), decomposed)
  }
  canonical_reorder(decomposed)
  let chars : Array[Char] = []
  for codepoint in decomposed {
    match codepoint.to_char() {
      Some(char) => chars.push(char)
      None => ()
    }
  }
  String::from_array(chars)
}
