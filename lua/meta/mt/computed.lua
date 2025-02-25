require 'meta.table'
local computable, save =
  require "meta.mt.computable",
  table.save

return function(self, k)
  if type(self)=='table' and k then local g = getmetatable(self)
  if g then
  if type(k)~='string' then
    return table.index(self, k) or table.interval(self, k)
  end
  return g[k]
    or computable(self, g.__computable, k)
    or save(self, k, computable(self, g.__computed, k))
  end end end