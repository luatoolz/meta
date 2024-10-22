local t=require "meta"
local is=t.is
return function(x) return (type(x)=='table' and is.similar(t.set, x)) and true or false end