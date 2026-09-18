///|
priv struct KeyedString {
  value : String
  key : SortKey
  original_index : Int
}

///|
/// A run of strings that compare equal at one collator's configured strength.
pub(all) struct CollationGroup {
  representative : String
  values : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub fn CollationGroup::representative(self : CollationGroup) -> String {
  self.representative
}

///|
pub fn CollationGroup::values(self : CollationGroup) -> Array[String] {
  self.values.copy()
}

///|
pub fn CollationGroup::length(self : CollationGroup) -> Int {
  self.values.length()
}

///|
/// A sorted, immutable string index with cached collation keys.
pub(all) struct CollationIndex {
  collator : Collator
  indexed_values : Array[String]
  indexed_keys : Array[SortKey]
}

///|
fn Collator::compare_keys(
  self : Collator,
  left : SortKey,
  right : SortKey,
) -> Ordering {
  let primary = compare_level(left.primary, right.primary)
  if primary != Equal || strength_rank(self.strength()) == 1 {
    return primary
  }
  let secondary = compare_level(left.secondary, right.secondary)
  if secondary != Equal || strength_rank(self.strength()) == 2 {
    return secondary
  }
  let tertiary = compare_level(left.tertiary, right.tertiary)
  if tertiary != Equal || strength_rank(self.strength()) == 3 {
    return tertiary
  }
  let quaternary = compare_level(left.quaternary, right.quaternary)
  if quaternary != Equal || strength_rank(self.strength()) == 4 {
    return quaternary
  }
  compare_level(left.identical, right.identical)
}

///|
fn ordering_as_int(ordering : Ordering) -> Int {
  match ordering {
    Less => -1
    Equal => 0
    Greater => 1
  }
}

///|
fn Collator::keyed(
  self : Collator,
  values : Array[String],
) -> Array[KeyedString] {
  let result : Array[KeyedString] = []
  for index, value in values {
    result.push({ value, key: self.sort_key(value), original_index: index, })
  }
  result
}

///|
fn Collator::sort_keyed(self : Collator, entries : Array[KeyedString]) -> Unit {
  entries.sort_by((left, right) => {
    let compared = self.compare_keys(left.key, right.key)
    if compared == Equal {
      left.original_index - right.original_index
    } else {
      ordering_as_int(compared)
    }
  })
}

///|
/// Return a stable collation-ordered copy. The input array is not modified.
pub fn Collator::sort(self : Collator, values : Array[String]) -> Array[String] {
  let entries = self.keyed(values)
  self.sort_keyed(entries)
  entries.map(entry => entry.value)
}

///|
/// Return whether values are already ordered for this collator.
pub fn Collator::is_sorted(self : Collator, values : Array[String]) -> Bool {
  if values.length() < 2 {
    return true
  }
  let mut previous = self.sort_key(values[0])
  for index = 1; index < values.length(); index = index + 1 {
    let current = self.sort_key(values[index])
    if self.compare_keys(previous, current) == Greater {
      return false
    }
    previous = current
  }
  true
}

///|
/// Group adjacent collation-equal values after a stable sort.
pub fn Collator::group_equal(
  self : Collator,
  values : Array[String],
) -> Array[CollationGroup] {
  let entries = self.keyed(values)
  self.sort_keyed(entries)
  let groups : Array[CollationGroup] = []
  let mut previous_key : SortKey? = None
  for entry in entries {
    match previous_key {
      Some(key) if self.compare_keys(key, entry.key) == Equal =>
        groups[groups.length() - 1].values.push(entry.value)
      _ => groups.push({ representative: entry.value, values: [entry.value], })
    }
    previous_key = Some(entry.key)
  }
  groups
}

///|
/// Remove collation-equal duplicates, retaining the first input occurrence.
pub fn Collator::deduplicate(
  self : Collator,
  values : Array[String],
) -> Array[String] {
  self.group_equal(values).map(group => group.representative)
}

///|
/// Return the least value, or `None` for an empty input.
pub fn Collator::minimum(self : Collator, values : Array[String]) -> String? {
  if values.length() == 0 {
    return None
  }
  let mut best = values[0]
  let mut best_key = self.sort_key(best)
  for index = 1; index < values.length(); index = index + 1 {
    let candidate_key = self.sort_key(values[index])
    if self.compare_keys(candidate_key, best_key) == Less {
      best = values[index]
      best_key = candidate_key
    }
  }
  Some(best)
}

///|
/// Return the greatest value, or `None` for an empty input.
pub fn Collator::maximum(self : Collator, values : Array[String]) -> String? {
  if values.length() == 0 {
    return None
  }
  let mut best = values[0]
  let mut best_key = self.sort_key(best)
  for index = 1; index < values.length(); index = index + 1 {
    let candidate_key = self.sort_key(values[index])
    if self.compare_keys(candidate_key, best_key) == Greater {
      best = values[index]
      best_key = candidate_key
    }
  }
  Some(best)
}

///|
/// Build an immutable index for repeated lookup and range queries.
pub fn CollationIndex::new(
  collator : Collator,
  values : Array[String],
) -> CollationIndex {
  let entries = collator.keyed(values)
  collator.sort_keyed(entries)
  {
    collator,
    indexed_values: entries.map(entry => entry.value),
    indexed_keys: entries.map(entry => entry.key),
  }
}

///|
pub fn CollationIndex::length(self : CollationIndex) -> Int {
  self.indexed_values.length()
}

///|
pub fn CollationIndex::is_empty(self : CollationIndex) -> Bool {
  self.indexed_values.length() == 0
}

///|
pub fn CollationIndex::values(self : CollationIndex) -> Array[String] {
  self.indexed_values.copy()
}

///|
fn CollationIndex::lower_bound_key(
  self : CollationIndex,
  target : SortKey,
) -> Int {
  let mut low = 0
  let mut high = self.indexed_keys.length()
  while low < high {
    let middle = low + (high - low) / 2
    if self.collator.compare_keys(self.indexed_keys[middle], target) == Less {
      low = middle + 1
    } else {
      high = middle
    }
  }
  low
}

///|
fn CollationIndex::upper_bound_key(
  self : CollationIndex,
  target : SortKey,
) -> Int {
  let mut low = 0
  let mut high = self.indexed_keys.length()
  while low < high {
    let middle = low + (high - low) / 2
    if self.collator.compare_keys(self.indexed_keys[middle], target) == Greater {
      high = middle
    } else {
      low = middle + 1
    }
  }
  low
}

///|
/// Return the insertion position before all values equal to `target`.
pub fn CollationIndex::lower_bound(
  self : CollationIndex,
  target : String,
) -> Int {
  self.lower_bound_key(self.collator.sort_key(target))
}

///|
/// Return the insertion position after all values equal to `target`.
pub fn CollationIndex::upper_bound(
  self : CollationIndex,
  target : String,
) -> Int {
  self.upper_bound_key(self.collator.sort_key(target))
}

///|
/// Return all indexed values equal to `target` at configured strength.
pub fn CollationIndex::equal_range(
  self : CollationIndex,
  target : String,
) -> Array[String] {
  let key = self.collator.sort_key(target)
  let first = self.lower_bound_key(key)
  let last = self.upper_bound_key(key)
  let result : Array[String] = []
  for index = first; index < last; index = index + 1 {
    result.push(self.indexed_values[index])
  }
  result
}

///|
/// Return values in the half-open collation interval `[lower, upper)`.
///
/// An empty array is returned when the bounds compare equal or are reversed.
pub fn CollationIndex::range(
  self : CollationIndex,
  lower : String,
  upper : String,
) -> Array[String] {
  let lower_key = self.collator.sort_key(lower)
  let upper_key = self.collator.sort_key(upper)
  if self.collator.compare_keys(lower_key, upper_key) != Less {
    return []
  }
  let first = self.lower_bound_key(lower_key)
  let last = self.lower_bound_key(upper_key)
  let result : Array[String] = []
  for index = first; index < last; index = index + 1 {
    result.push(self.indexed_values[index])
  }
  result
}

///|
/// Count values equal to `target` without allocating an equal-range array.
pub fn CollationIndex::count_equal(
  self : CollationIndex,
  target : String,
) -> Int {
  let key = self.collator.sort_key(target)
  self.upper_bound_key(key) - self.lower_bound_key(key)
}

///|
pub fn CollationIndex::contains(self : CollationIndex, target : String) -> Bool {
  self.count_equal(target) > 0
}
