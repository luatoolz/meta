require 'meta.gmt'
local this, g
return function(o)
  this=this or require 'meta.iter'
  g=g or getmetatable(this)
  return type(o)=='table' and rawequal(g,getmetatable(o)) end