local mt, computable, save, pkg =
  require "meta.mt.mt",
  require "meta.mt.computable",
  table.save,
  ...
local _ = pkg

return function(self, key, sub, ...)
  if type(self)~='table' or type(key)=='nil' then return nil end
--  if type(key)=='number' or (type(key)=='table' and #key==2 and type(key[1])=='number') then return table.interval(self, key) end
--  if type(self)~='table' or type(key)~='string' or key=='' or not getmetatable(self) then
--    return pkg:error('await table+string, got', type(self), type(key)) end
  return mt(self)[key]
    or table.index(self, key)
    or table.interval(self, key)
    or computable(self, mt(self).__computable, key, ...)
    or save(sub and rawget(self, sub) or self, key, computable(self, mt(self).__computed, key, ...))
  end