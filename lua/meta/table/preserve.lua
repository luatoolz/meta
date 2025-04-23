require 'meta.gmt'
--local callable = require 'meta.is.callable'
local mt=getmetatable
return function(self, alt) return (type(self)=='table' and mt(self) and mt(self).__preserve) and setmetatable({},mt(self) or mt(table)) or alt end