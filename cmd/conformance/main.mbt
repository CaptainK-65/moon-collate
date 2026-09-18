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
enum FixtureProfile {
  Short
  Full
} derive(Debug, Eq)

///|
struct ConformanceOptions {
  shifted : Bool
  profile : FixtureProfile
  fixture : String?
} derive(Debug, Eq)

///|
fn default_fixture(shifted : Bool, profile : FixtureProfile) -> String {
  let name = match (shifted, profile) {
    (true, Short) => "CollationTest_SHIFTED_SHORT.txt"
    (true, Full) => "CollationTest_SHIFTED.txt"
    (false, Short) => "CollationTest_NON_IGNORABLE_SHORT.txt"
    (false, Full) => "CollationTest_NON_IGNORABLE.txt"
  }
  "third_party/unicode/uca-17.0.0/collation-test/CollationTest/" + name
}

///|
fn parse_options(args : Array[String]) -> ConformanceOptions? {
  let mut shifted = false
  let mut profile = FixtureProfile::Short
  let mut fixture : String? = None
  let mut index = 1
  while index < args.length() {
    match args[index] {
      "--shifted" => shifted = true
      "--non-ignorable" => shifted = false
      "--short" => profile = FixtureProfile::Short
      "--full" => profile = FixtureProfile::Full
      "--fixture" => {
        if index + 1 >= args.length() {
          return None
        }
        index = index + 1
        fixture = Some(args[index])
      }
      value => {
        if value.has_prefix("--") || fixture is Some(_) {
          return None
        }
        fixture = Some(value)
      }
    }
    index = index + 1
  }
  Some({ shifted, profile, fixture, })
}

///|
fn usage() -> String {
  "usage: conformance [--shifted|--non-ignorable] [--short|--full] " +
  "[--fixture PATH]"
}

///|
async fn main {
  let args = @env.args()
  guard parse_options(args) is Some(options) else { fail(usage()) }
  let path = options.fixture.unwrap_or(
    default_fixture(options.shifted, options.profile),
  )
  let content = @fs.read_file(path).text()
  let collator = if options.shifted {
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
