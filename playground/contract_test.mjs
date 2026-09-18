import { pathToFileURL } from "node:url";

if (process.argv.length !== 3) {
  throw new Error("usage: node playground/contract_test.mjs PATH_TO_ADAPTER");
}

globalThis.CustomEvent = class CustomEvent {
  constructor(type) {
    this.type = type;
  }
};
globalThis.dispatchEvent = () => true;

await import(pathToFileURL(process.argv[2]).href);

if (typeof globalThis.MoonCollate?.run !== "function") {
  throw new Error("MoonCollate.run was not installed");
}

const run = (mode, left, right = "", options = "") =>
  JSON.parse(globalThis.MoonCollate.run(mode, left, right, options));

const comparison = run("compare", "file2", "file10", "numeric=true");
if (comparison.value !== -1 || comparison.ordering !== "Less") {
  throw new Error(`unexpected comparison: ${JSON.stringify(comparison)}`);
}

const sorted = run("sort", "file10\nfile2\nfile1", "", "numeric=true");
if (JSON.stringify(sorted) !== JSON.stringify(["file1", "file2", "file10"])) {
  throw new Error(`unexpected sort: ${JSON.stringify(sorted)}`);
}

const explanation = run("explain", "café");
if (explanation.normalized !== "café" || explanation.steps.length === 0) {
  throw new Error(`unexpected explanation: ${JSON.stringify(explanation)}`);
}

const invalid = run("unknown", "value");
if (invalid.error !== "unknown operation") {
  throw new Error(`unexpected error contract: ${JSON.stringify(invalid)}`);
}

console.log("browser adapter contract passed");
