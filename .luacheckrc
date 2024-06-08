stds.meta = {
  globals = {"math", "string", "table", "package"},
}
ignore = {
  "212/%.%.%.",
  "131/_",
  "211/_",
  "211/meta",
  "211/pkgloaded",
  "212/_",
  "213/_",
}
std = "min+meta"
files["spec"] = {std = "+busted"}
allow_defined = true
allow_defined_top = true
max_comment_line_length = 512
max_string_line_length = 512
max_code_line_length = 512
max_line_length = 512
unused_args = false
self = false
