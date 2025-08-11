require 'compat53'
--local call  = require 'meta.call'
local tuple = require 'meta.tuple'
local is    = {
  callable  = require 'meta.is.callable',
}

-- specific type checks handled in every caller
return function(self, key)
  if type(self)=='table' and getmetatable(self) then
  local g = getmetatable(self)
  local rv
  if type(key)=='string' and g[key] then return g[key] end
  for _,f in ipairs(rawget(g, '__indexer') or g) do
--    if is.callable(f) then rv=tuple.good(call(f, self, key)) elseif
    if is.callable(f) then rv=tuple.good(f(self, key)) elseif
      type(f)=='table' then rv=tuple.good(f[key]) end
    if rv then return rv() end
  end end return nil end