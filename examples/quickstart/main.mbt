///|
fn main {
  let collator = @collate.default_collator()
  println("MoonCollate v\{@collate.VERSION}")
  println(
    "compare(resume, résumé): \{collator.compare("resume", "résumé").to_string()}",
  )
  let natural = collator.with_numeric(true)
  println(
    "numeric sort: \{natural.sort(["file10", "file2", "file1"]).to_json().stringify()}",
  )
  let primary = collator.with_strength(@collate.Strength::Primary)
  let index = @collate.CollationIndex::new(primary, ["Zulu", "é", "E", "apple"])
  println("range [e, Zulu): \{index.range("e", "Zulu").to_json().stringify()}")
  println("count equal to e: \{index.count_equal("e")}")
  let report = collator.compare_detailed("e", "é")
  match report.difference() {
    Some(difference) =>
      println("first difference: \{difference.level().to_string()}")
    None => println("first difference: none")
  }
}
