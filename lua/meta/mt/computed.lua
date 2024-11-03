local mt = require "meta.mt"
local computable, save =
  mt.computable,
  table.save

return function(self, key)
  if type(self)~='table' or type(key)~='string' or not getmetatable(self) then return nil end
  return mt(self)[key]
    or computable(self, mt(self).__computable, key)
    or save(self, key, computable(self, mt(self).__computed, key))
  end