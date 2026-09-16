///|
struct CompareResponse {
  left : String
  right : String
  ordering : String
  value : Int
  left_key : @collate.SortKey
  right_key : @collate.SortKey
} derive(ToJson)

///|
struct ErrorResponse {
  error : String
} derive(ToJson)

///|
fn ordering_value(value : @collate.Ordering) -> Int {
  match value {
    Less => -1
    Equal => 0
    Greater => 1
  }
}

///|
fn configure(raw : String) -> @collate.Collator {
  let mut collator = @collate.default_collator()
  for option in raw.split(",") {
    match option {
      "strength=primary" =>
        collator = collator.with_strength(@collate.Strength::Primary)
      "strength=secondary" =>
        collator = collator.with_strength(@collate.Strength::Secondary)
      "strength=tertiary" =>
        collator = collator.with_strength(@collate.Strength::Tertiary)
      "strength=quaternary" =>
        collator = collator.with_strength(@collate.Strength::Quaternary)
      "strength=identical" =>
        collator = collator.with_strength(@collate.Strength::Identical)
      "alternate=shifted" =>
        collator = collator.with_alternate(@collate.AlternateHandling::Shifted)
      "case=upper" =>
        collator = collator.with_case_first(@collate.CaseFirst::UpperFirst)
      "case=lower" =>
        collator = collator.with_case_first(@collate.CaseFirst::LowerFirst)
      "backwards=true" => collator = collator.with_backwards_secondary(true)
      "numeric=true" => collator = collator.with_numeric(true)
      _ => ()
    }
  }
  collator
}

///|
fn compare_json(
  collator : @collate.Collator,
  left : String,
  right : String,
) -> String {
  let ordering = collator.compare(left, right)
  ToJson::to_json(CompareResponse::{
    left,
    right,
    ordering: ordering.to_string(),
    value: ordering_value(ordering),
    left_key: collator.sort_key(left),
    right_key: collator.sort_key(right),
  }).stringify()
}

///|
fn sort_json(collator : @collate.Collator, source : String) -> String {
  let values : Array[String] = []
  for line in source.split("\n") {
    let value = line.to_owned().trim().to_owned()
    if value.length() > 0 {
      values.push(value)
    }
  }
  values.sort_by((left, right) => ordering_value(collator.compare(left, right)))
  values.to_json().stringify()
}

///|
/// Single string boundary used by the JavaScript adapter.
pub fn run(
  mode : String,
  left : String,
  right : String,
  options : String,
) -> String {
  let collator = configure(options)
  match mode {
    "compare" => compare_json(collator, left, right)
    "key" => collator.sort_key(left).to_json().stringify()
    "explain" => collator.explain(left).to_json().stringify()
    "sort" => sort_json(collator, left)
    _ =>
      ToJson::to_json(ErrorResponse::{ error: "unknown operation", }).stringify()
  }
}
