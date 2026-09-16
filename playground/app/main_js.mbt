///|
extern "js" fn install_lab(
  run : (String, String, String, String) -> String,
) -> Unit =
  #|function(run) {
  #|  globalThis.MoonCollate = Object.freeze({ run });
  #|  globalThis.dispatchEvent(new CustomEvent("mooncollate:ready"));
  #|}

///|
fn main {
  install_lab(@model.run)
}
