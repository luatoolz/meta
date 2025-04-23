local mt, loader, pkg =
  require "meta.mt.mt",
  require "meta.mt.loader",
  ...

return function(self, key)
  if type(self)~='table' or type(key)~='string' or key=='' or not getmetatable(self) then
    return pkg:error('await table+string, got', type(self), type(key)) end
  return mt(self)[key]
    or (loader(self) or {})[key]
  end