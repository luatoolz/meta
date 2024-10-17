require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
local meta = require "meta"
local cache = meta.cache
local is = meta.is
local typename = cache.type

return setmetatable({
  function(o) return typename[o] or (getmetatable(o) or {}).__name end,
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
