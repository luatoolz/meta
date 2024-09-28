require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"
local meta = require "meta"
local cache = meta.cache
local is = meta.is
local typename = cache.type

return setmetatable({
  function(o) return typename[o] or ((type(o)=='table' and getmetatable(o)) and typename[getmetatable(o)] or getmetatable(o).__name) or nil end,
}, {
  __add=table.append_unique,
  __pow=function(self, f) return is.callable(f) and (self+f) or self end,
  __call=function(self, t)
    if type(t)=='nil' then return 'nil' end
      local rv
      for _,f in ipairs(self) do
        rv=f(t)
        if rv then return rv end
      end return nil end,})
