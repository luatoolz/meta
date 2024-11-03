local mt = require "meta.mt"
local loader = mt.loader
return function(self, key)
  if type(self)~='table' or type(key)~='string' or not getmetatable(self) then return nil end
  return mt(self)[key]
    or loader(self, key)
  end