local no = require "meta.no"

no.asserts("ends", function(a, b, ...)
  return (type(a)=='string' and type(b)=='string' and b:sub(-#a)==a and true or nil), ...
end,
"Expected module name ending to have value.\nExpected:\n%s\nPassed in:\n%s\n",
"Expected module name ending not to have value.\nExpected:\n%s\nPassed in:\n%s\n"
)
