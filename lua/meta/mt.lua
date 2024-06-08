require "compat53"

return function(self, meta)
  if type(self) ~= 'table' then return nil end
  assert(type(self) == 'table', 'await table, got ' .. type(self))
  local existing = getmetatable(self)
  if not existing then
    setmetatable(self, meta or {})
  end
  if not meta or not existing then
    return getmetatable(self)
  end

  local newmeta = {}
  if type(existing)=='table' then
    for k,v in pairs(existing) do
      rawset(newmeta, k, v)
    end
  end
  if existing ~= meta then
    for k,v in pairs(meta) do
      rawset(newmeta, k, v)
    end
  end
  setmetatable(self, newmeta)
  return newmeta
end
