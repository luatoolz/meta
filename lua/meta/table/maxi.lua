require "compat53"
local maxn = rawget(table, 'maxn')
return function(self) return type(self)=='table' and (maxn and maxn(self) or #self) or nil end