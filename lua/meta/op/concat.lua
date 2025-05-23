require 'meta.gmt'
return function(self, it) if type(self)=='table' then return type(it)=='nil' and self or (setmetatable(self[{0}],getmetatable(self))+it) end end