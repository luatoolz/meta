require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
return {
  callable = function(o) return type(o)=='function' or ((type(o)=='table' or type(o)=='userdata') and type((getmetatable(o) or {}).__call)=='function') end,
  boolean  = function(o) return type(o)=='boolean' end,
  table    = function(o) return type(o)=='table' and not getmetatable(o) end,
  func     = function(o) return type(o)=='function' end,
  falsy    = function() return false end,
}