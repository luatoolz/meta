require "meta.table"
return function(x) return type(x)=='table' and (type(getmetatable(x))=='nil' or getmetatable(x)==table) and true or false end