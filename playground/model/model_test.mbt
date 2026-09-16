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
