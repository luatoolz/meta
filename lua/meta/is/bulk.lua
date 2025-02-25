local iter = require 'meta.iter'
local is = {
  like = require 'meta.is.like',
}

return function(x)
local g = x and getmetatable(x) or {}
return type(x)=='function' or
(type(x)=='table' and (
  ((not getmetatable(x)) and (type(next(x))=='nil' or #x>0)) or
  is.like(iter,x) or
  rawget(x, '__array') or
  g.__array or
  g.__arraytype or
  g.__jsontype=='array' or
  g.__name=='json.array'
)) and true or nil end