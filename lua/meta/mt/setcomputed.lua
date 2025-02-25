local computable, save =
  require "meta.mt.computable",
  table.save

return function(self, k, v)
  local g = getmetatable(self) or {}
  if g.__computable[k] then
    return computable(self, g.__computable, k, v)
  end
  if g.__computed[k] then
    return save(self, k, computable(self, g.__computed, k, v))
  end
  rawset(self, k, v)
end