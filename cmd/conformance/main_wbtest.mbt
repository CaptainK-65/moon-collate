///|
test "conformance options are order independent" {
  guard parse_options(["conformance", "--full", "--shifted"]) is Some(options) else {
    fail("expected valid options")
  }
  assert_true(options.shifted)
  assert_true(options.profile is FixtureProfile::Full)
  assert_eq(options.fixture, None)
  assert_eq(
    default_fixture(options.shifted, options.profile),
    "third_party/unicode/uca-17.0.0/collation-test/CollationTest/CollationTest_SHIFTED.txt",
  )
}

///|
test "explicit fixture composes with shifted mode" {
  guard parse_options([
      "conformance", "--shifted", "--fixture", "fixtures/custom.txt",
    ])
    is Some(options) else {
    fail("expected valid options")
  }
  assert_true(options.shifted)
  assert_eq(options.fixture, Some("fixtures/custom.txt"))
}

///|
test "legacy positional fixture remains supported" {
  guard parse_options(["conformance", "fixtures/custom.txt"]) is Some(options) else {
    fail("expected valid options")
  }
  assert_false(options.shifted)
  assert_eq(options.fixture, Some("fixtures/custom.txt"))
}

///|
test "conformance options reject incomplete and unknown arguments" {
  assert_eq(parse_options(["conformance", "--fixture"]), None)
  assert_eq(parse_options(["conformance", "--unknown"]), None)
  assert_eq(parse_options(["conformance", "one.txt", "two.txt"]), None)
}
