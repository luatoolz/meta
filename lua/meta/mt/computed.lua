local mt, computable, save, pkg =
  require "meta.mt.mt",
  require "meta.mt.computable",
  table.save,
  ...

return function(self, key, sub, ...)
  if type(self)~='table' or type(key)~='string' or key=='' or not getmetatable(self) then
    return pkg:error('await table+string, got', type(self), type(key)) end
  return mt(self)[key]
    or computable(self, mt(self).__computable, key, ...)
    or save(sub and rawget(self, sub) or self, key, computable(self, mt(self).__computed, key, ...))
  end