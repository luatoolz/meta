require "compat53"

local cache = require "meta.cache"

return function(self, meta, cached)
--  if type(self) ~= 'table' then return nil end
  assert(type(self) == 'table', 'await arg#1 table, got ' .. type(self))
  if meta then assert(type(meta) == 'table', 'await arg#2 table, got ' .. type(meta)) end
  if not meta then return getmetatable(self) or getmetatable(setmetatable(self, {})) end
  local existing = getmetatable(self)
  if not existing then
    setmetatable(self, meta)
  elseif existing ~= meta then
    for k,v in pairs(meta) do
      if rawget(existing, k)~=v then rawset(existing, k, v) end
    end
  end
  if type(cached)=='table' then
    local name, normalize, _ = table.unpack(cached)
    cache(name, normalize, self) --new and self or nil)
  end
  return self
end
