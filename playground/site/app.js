const byId = (id) => document.getElementById(id);

const ui = {
  runtime: byId("runtime-status"),
  strength: byId("strength"),
  alternate: byId("alternate"),
  caseFirst: byId("case-first"),
  numeric: byId("numeric"),
  backwards: byId("backwards"),
  reset: byId("reset-options"),
  left: byId("left-input"),
  right: byId("right-input"),
  sort: byId("sort-input"),
  explain: byId("explain-input"),
  badge: byId("comparison-badge"),
  empty: byId("empty-result"),
  error: byId("error-result"),
  content: byId("result-content"),
  summary: byId("result-summary"),
  sorted: byId("sorted-list"),
  keyGrid: byId("key-grid"),
  raw: byId("raw-json"),
  copy: byId("copy-result"),
  compareButton: byId("compare-button"),
  sortButton: byId("sort-button"),
  explainButton: byId("explain-button")
};

let mode = "compare";
let lastJson = "";

const examples = {
  cafe: { left: "café", right: "cafe\u0301", options: {} },
  files: { left: "file2", right: "file10", options: { numeric: true } },
  punctuation: { left: "coop", right: "co-op", options: { strength: "primary", alternate: "shifted" } },
  languages: { left: "東京", right: "서울", options: { strength: "tertiary" } }
};

function runtimeReady() {
  const ready = typeof globalThis.MoonCollate?.run === "function";
  ui.runtime.className = `runtime ${ready ? "ready" : "waiting"}`;
  ui.runtime.innerHTML = `<span></span>${ready ? "MoonBit ready" : "Loading MoonBit"}`;
  [ui.compareButton, ui.sortButton, ui.explainButton].forEach((button) => { button.disabled = !ready; });
  return ready;
}

function optionString() {
  return [
    `strength=${ui.strength.value}`,
    `alternate=${ui.alternate.value}`,
    `case=${ui.caseFirst.value}`,
    `numeric=${ui.numeric.checked}`,
    `backwards=${ui.backwards.checked}`
  ].join(",");
}

function setOptions(values = {}) {
  ui.strength.value = values.strength ?? "tertiary";
  ui.alternate.value = values.alternate ?? "non-ignorable";
  ui.caseFirst.value = values.caseFirst ?? "off";
  ui.numeric.checked = values.numeric ?? false;
  ui.backwards.checked = values.backwards ?? false;
}

function showError(error) {
  ui.empty.classList.add("hidden");
  ui.content.classList.add("hidden");
  ui.error.classList.remove("hidden");
  ui.error.textContent = error instanceof Error ? error.message : String(error);
  ui.copy.disabled = true;
}

function weightText(values = []) {
  if (!values.length) return "—";
  return values.map((value) => value.toString(16).toUpperCase().padStart(4, "0")).join(" · ");
}

function addKeyCard(title, values) {
  const card = document.createElement("article");
  card.className = "key-card";
  const heading = document.createElement("h4");
  heading.textContent = title;
  const code = document.createElement("code");
  code.textContent = weightText(values);
  card.append(heading, code);
  ui.keyGrid.append(card);
}

function renderKeys(key, prefix = "") {
  const levels = ["primary", "secondary", "tertiary", "quaternary", "identical"];
  levels.forEach((level) => addKeyCard(`${prefix}${level}`, key?.[level] ?? []));
}

function showResult(data) {
  lastJson = JSON.stringify(data, null, 2);
  ui.raw.textContent = lastJson;
  ui.empty.classList.add("hidden");
  ui.error.classList.add("hidden");
  ui.content.classList.remove("hidden");
  ui.sorted.classList.add("hidden");
  ui.sorted.replaceChildren();
  ui.keyGrid.replaceChildren();
  ui.copy.disabled = false;

  if (mode === "compare") {
    const glyph = data.value < 0 ? "<" : data.value > 0 ? ">" : "=";
    ui.badge.textContent = glyph;
    ui.summary.innerHTML = `<code>${escapeHtml(data.left)}</code> ${glyph} <code>${escapeHtml(data.right)}</code>`;
    renderKeys(data.left_key, "Left · ");
    renderKeys(data.right_key, "Right · ");
  } else if (mode === "sort") {
    ui.summary.textContent = `${data.length} values in collation order`;
    ui.sorted.classList.remove("hidden");
    data.forEach((value) => {
      const row = document.createElement("div");
      row.className = "sorted-item";
      const text = document.createElement("span");
      text.textContent = value;
      row.append(text);
      ui.sorted.append(row);
    });
  } else {
    ui.summary.innerHTML = `Normalized to <code>${escapeHtml(data.normalized)}</code> · ${data.steps.length} mapping steps`;
    renderKeys(data.key);
  }
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({
    "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#039;"
  })[character]);
}

function run(operation, left, right = "") {
  if (!runtimeReady()) {
    showError("The MoonBit runtime has not finished loading.");
    return;
  }
  try {
    const raw = globalThis.MoonCollate.run(operation, left, right, optionString());
    const data = JSON.parse(raw);
    if (data.error) throw new Error(data.error);
    showResult(data);
  } catch (error) {
    showError(error);
  }
}

function changeMode(nextMode) {
  mode = nextMode;
  document.querySelectorAll("[data-mode]").forEach((tab) => tab.classList.toggle("active", tab.dataset.mode === mode));
  ["compare", "sort", "explain"].forEach((name) => byId(`${name}-view`).classList.toggle("hidden", name !== mode));
  ui.empty.classList.remove("hidden");
  ui.error.classList.add("hidden");
  ui.content.classList.add("hidden");
}

document.querySelectorAll("[data-mode]").forEach((tab) => tab.addEventListener("click", () => changeMode(tab.dataset.mode)));
document.querySelectorAll("[data-example]").forEach((button) => button.addEventListener("click", () => {
  const example = examples[button.dataset.example];
  ui.left.value = example.left;
  ui.right.value = example.right;
  setOptions(example.options);
}));

ui.compareButton.addEventListener("click", () => run("compare", ui.left.value, ui.right.value));
ui.sortButton.addEventListener("click", () => run("sort", ui.sort.value));
ui.explainButton.addEventListener("click", () => run("explain", ui.explain.value));
ui.reset.addEventListener("click", () => setOptions());
ui.copy.addEventListener("click", async () => {
  await navigator.clipboard.writeText(lastJson);
  const previous = ui.copy.textContent;
  ui.copy.textContent = "Copied";
  setTimeout(() => { ui.copy.textContent = previous; }, 1200);
});

document.addEventListener("keydown", (event) => {
  if ((event.ctrlKey || event.metaKey) && event.key === "Enter") {
    event.preventDefault();
    if (mode === "compare") ui.compareButton.click();
    if (mode === "sort") ui.sortButton.click();
    if (mode === "explain") ui.explainButton.click();
  }
});

globalThis.addEventListener("mooncollate:ready", runtimeReady);
runtimeReady();
