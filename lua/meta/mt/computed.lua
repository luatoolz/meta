local itable, computable, mt, save =
  require 'meta.mt.table',
  require 'meta.mt.computable',
  require 'meta.mt.mt',
  require 'meta.table.save'
return function(self, k)
  if type(self)=='table' and type(k)~='nil' then
  return mt(self)[k]
    or itable(self, k)
    or computable(self, mt(self).__computable, k)
    or save(self, k, computable(self, mt(self).__computed, k))
  end return nil end