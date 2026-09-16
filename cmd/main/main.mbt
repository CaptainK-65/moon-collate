///|
fn usage() -> String {
  (
    #|MoonCollate — Unicode 17.0.0 collation toolkit
    #|
    #|Usage:
    #|  moon run cmd/main -- compare [options] LEFT RIGHT
    #|  moon run cmd/main -- key [options] TEXT
    #|  moon run cmd/main -- explain [options] TEXT
    #|  moon run cmd/main -- sort [options] TEXT...
    #|  moon run cmd/main -- version
    #|
    #|Options:
    #|  --strength primary|secondary|tertiary|quaternary|identical
    #|  --shifted                  Ignore variables before quaternary level
    #|  --numeric                  Compare ASCII digit runs numerically
    #|  --upper-first              Sort uppercase before lowercase
    #|  --lower-first              Sort lowercase before uppercase
    #|  --backwards-secondary      Compare secondary weights in reverse
  )
}

///|
fn parse_strength(value : String) -> @collate.Strength? {
  match value {
    "primary" => Some(@collate.Strength::Primary)
    "secondary" => Some(@collate.Strength::Secondary)
    "tertiary" => Some(@collate.Strength::Tertiary)
    "quaternary" => Some(@collate.Strength::Quaternary)
    "identical" => Some(@collate.Strength::Identical)
    _ => None
  }
}

///|
fn parse_options(
  args : Array[String],
  start : Int,
) -> (@collate.Collator, Array[String])? {
  let mut collator = @collate.default_collator()
  let operands : Array[String] = []
  let mut index = start
  while index < args.length() {
    match args[index] {
      "--strength" => {
        if index + 1 >= args.length() {
          return None
        }
        match parse_strength(args[index + 1]) {
          Some(strength) => collator = collator.with_strength(strength)
          None => return None
        }
        index = index + 2
      }
      "--shifted" => {
        collator = collator.with_alternate(@collate.AlternateHandling::Shifted)
        index = index + 1
      }
      "--numeric" => {
        collator = collator.with_numeric(true)
        index = index + 1
      }
      "--upper-first" => {
        collator = collator.with_case_first(@collate.CaseFirst::UpperFirst)
        index = index + 1
      }
      "--lower-first" => {
        collator = collator.with_case_first(@collate.CaseFirst::LowerFirst)
        index = index + 1
      }
      "--backwards-secondary" => {
        collator = collator.with_backwards_secondary(true)
        index = index + 1
      }
      value => {
        operands.push(value)
        index = index + 1
      }
    }
  }
  Some((collator, operands))
}

///|
fn ordering_number(ordering : @collate.Ordering) -> Int {
  match ordering {
    Less => -1
    Equal => 0
    Greater => 1
  }
}

///|
fn command_compare(
  collator : @collate.Collator,
  operands : Array[String],
) -> Bool {
  if operands.length() != 2 {
    return false
  }
  let result = collator.compare(operands[0], operands[1])
  println(
    (
      {
        "left": operands[0].to_json(),
        "right": operands[1].to_json(),
        "ordering": result.to_string().to_json(),
        "value": ordering_number(result).to_json(),
      } : Json).stringify(indent=2),
  )
  true
}

///|
fn command_key(collator : @collate.Collator, operands : Array[String]) -> Bool {
  if operands.length() != 1 {
    return false
  }
  println(collator.sort_key(operands[0]).to_json().stringify(indent=2))
  true
}

///|
fn command_explain(
  collator : @collate.Collator,
  operands : Array[String],
) -> Bool {
  if operands.length() != 1 {
    return false
  }
  println(collator.explain(operands[0]).to_json().stringify(indent=2))
  true
}

///|
fn command_sort(collator : @collate.Collator, operands : Array[String]) -> Bool {
  if operands.length() == 0 {
    return false
  }
  operands.sort_by((left, right) => {
    ordering_number(collator.compare(left, right))
  })
  println(operands.to_json().stringify(indent=2))
  true
}

///|
fn main {
  let args = @env.args()
  if args.length() < 2 {
    println(usage())
    return
  }
  if args[1] == "version" || args[1] == "--version" {
    println(
      "moon-collate {@collate.library_version()} (Unicode {@collate.unicode_version()}, UCA {@collate.uca_version()})",
    )
    return
  }
  match parse_options(args, 2) {
    None => println(usage())
    Some((collator, operands)) => {
      let accepted = match args[1] {
        "compare" => command_compare(collator, operands)
        "key" => command_key(collator, operands)
        "explain" => command_explain(collator, operands)
        "sort" => command_sort(collator, operands)
        _ => false
      }
      if !accepted {
        println(usage())
      }
    }
  }
}
