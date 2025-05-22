require 'compat53'
local tuple=require('meta.tuple')
return function(x) return (type(x)=='table' and rawequal(getmetatable(tuple), getmetatable(x) or nil)) and true or nil end