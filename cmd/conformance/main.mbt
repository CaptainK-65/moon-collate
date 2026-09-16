///|
fn parse_codepoint(value : StringView) -> Int? {
  try @string.parse_int(value, base=16) catch {
    _ => None
  } noraise {
    codepoint => Some(codepoint)
  }
}

///|
fn parse_test_string(line : StringView) -> String? {
  let uncommented = match line.to_owned().split_once("#") {
    Some((codepoints, _)) => codepoints
    None => line
  }
  let body = match uncommented.to_owned().split_once(";") {
    Some((codepoints, _)) => codepoints
    None => uncommented
  }
  let chars : Array[Char] = []
  for raw in body.to_owned().trim().to_owned().split(" ") {
    if raw.length() > 0 {
      guard parse_codepoint(raw) is Some(codepoint) else { return None }
      guard codepoint.to_char() is Some(char) else { return None }
      chars.push(char)
    }
  }
  if chars.length() == 0 {
    None
  } else {
    Some(String::from_array(chars))
  }
}

///|
async fn main {
  let args = @env.args()
  let shifted = args.length() > 1 && args[1] == "--shifted"
  let path = if shifted {
    "third_party/unicode/uca-17.0.0/collation-test/CollationTest/CollationTest_SHIFTED_SHORT.txt"
  } else if args.length() > 1 {
    args[1]
  } else {
    "third_party/unicode/uca-17.0.0/collation-test/CollationTest/CollationTest_NON_IGNORABLE_SHORT.txt"
  }
  let content = @fs.read_file(path).text()
  let collator = if shifted {
    @collate.default_collator().with_alternate(
      @collate.AlternateHandling::Shifted,
    )
  } else {
    @collate.default_collator()
  }
  let mut previous : String? = None
  let mut checked = 0
  let mut failures = 0
  for line in content.split("\n") {
    match parse_test_string(line) {
      None => ()
      Some(current) => {
        match previous {
          None => ()
          Some(left) => {
            checked = checked + 1
            if collator.compare(left, current) == @collate.Ordering::Greater {
              failures = failures + 1
              if failures <= 10 {
                println(
                  "out of order at vector " +
                  checked.to_string() +
                  ": " +
                  left.to_json().stringify() +
                  " > " +
                  current.to_json().stringify(),
                )
              }
            }
          }
        }
        previous = Some(current)
      }
    }
  }
  println(
    "checked " +
    checked.to_string() +
    " adjacent pairs; failures: " +
    failures.to_string(),
  )
  if failures > 0 {
    fail("Unicode collation conformance failed")
  }
}
