require "meta.gmt"
return {
  callable = require "meta.is.callable",
  boolean  = function(o) return type(o)=='boolean' end,
  table    = function(o) return type(o)=='table' and not getmetatable(o) end,
  func     = function(o) return type(o)=='function' end,
  falsy    = function() return false end,
  empty     =function(x) return type(x)=='table' and type(next(x))=='nil' end,
}