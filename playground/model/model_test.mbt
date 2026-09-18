///|
test "browser model compares through MoonCollate" {
  let response = run("compare", "a", "b", "strength=tertiary")
  assert_true(response.contains("\"ordering\":\"Less\""))
}

///|
test "browser model provides numeric sorting" {
  let response = run("sort", "file10\nfile2\nfile1", "", "numeric=true")
  inspect(response, content="[\"file1\",\"file2\",\"file10\"]")
}

///|
test "browser model accepts every documented configuration" {
  for
    strength in ["primary", "secondary", "tertiary", "quaternary", "identical"] {
    let response = run("compare", "a", "a", "strength=" + strength)
    assert_true(response.contains("\"ordering\":\"Equal\""))
  }
  let options = "alternate=shifted,case=upper,case=lower,backwards=true,numeric=true,ignored=true"
  assert_true(
    run("compare", "file2", "file10", options).contains("\"value\":-1"),
  )
}

///|
test "browser model exposes key, explanation, equality, and errors" {
  assert_true(run("key", "é", "", "").contains("\"primary\""))
  assert_true(run("explain", "é", "", "").contains("\"normalized\""))
  assert_true(run("compare", "a", "a", "").contains("\"value\":0"))
  inspect(
    run("unknown", "", "", ""),
    content="{\"error\":\"unknown operation\"}",
  )
}
