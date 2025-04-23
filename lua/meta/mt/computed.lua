local itable, computable, save =
  require "meta.mt.table",
  require "meta.mt.computable",
  table.save
return function(self, k)
  if type(self)=='table' and k then local g = getmetatable(self)
  if g then
  return g[k]
    or itable(self, k)
    or computable(self, g.__computable, k)
    or save(self, k, computable(self, g.__computed, k))
  end end end