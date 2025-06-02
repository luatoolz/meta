require 'compat53'
local call  = require 'meta.call'
local is    = {
  callable  = require 'meta.is.callable',
}
-- specific type checks handled in every caller
return function(self, k) if type(self)=='table' and getmetatable(self) and type(k)~='nil' then
  local g = getmetatable(self)
  local t = g.__indexer or g
  local rv = t[k]
  if rv then return rv end
  for _,f in ipairs(t) do if is.callable(f) then rv=call(f, self, k)
    elseif type(f)=='table' then rv=f[k] end
    if rv then return rv end end end return nil end