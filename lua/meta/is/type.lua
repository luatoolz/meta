local typed = require "meta.type"
return function(name, x) return name==typed(x) or name==nil or nil end