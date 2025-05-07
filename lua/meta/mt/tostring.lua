require 'meta.string'
local mt = getmetatable
return function(self) return (mt(self).__sep or string.sep):join(self[0], self) or '' end