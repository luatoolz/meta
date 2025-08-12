local mt = require 'meta.gmt'
local is

return function(x)
  is=is or require 'meta.is'
local g = x and mt(x)
return is.func(x) or
(is.table(x) and (
  (#x>0 and not getmetatable(x)) or
  is.iter(x) or
  rawget(x, '__array') or
  g.__array or
  g.__arraytype or
  g.__jsontype=='array' or
  g.__name=='json.array'
)) and true or nil end