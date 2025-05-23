require 'compat53'
local call  = require 'meta.call'
local tuple = require 'meta.tuple'

-- specific type checks handled in every caller
return function(self, key)
  if type(self)=='table' and getmetatable(self) then
  local g = getmetatable(self)
  local rv
  if type(key)=='string' and g[key] then return g[key] end
  for _,f in ipairs(rawget(g, '__indexer') or g) do
    rv = f and tuple.good(call(f, self, key))
    if rv then return rv() end
  end
  end end