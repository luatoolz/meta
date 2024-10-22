local t=require "meta"
local is=t.is
return function(x) return (type(x)=='table' and is.similar(t.array, x)) and true or false end