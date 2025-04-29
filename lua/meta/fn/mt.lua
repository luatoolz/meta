require 'meta.gmt'
return function(x) return type(x)~='nil' and getmetatable(x) or {} end