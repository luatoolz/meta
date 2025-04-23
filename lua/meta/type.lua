require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
local instance = require "meta.module.instance"
local mtype = require "meta.module.type"
local unroot = require "meta.module.unroot"
local is = {
  callable = require "meta.is.callable",
}

return setmetatable({
--  function(o) local m=mtype[o]; m=m and module(m); return  (getmetatable(o) or {}).__name or m.id end,
  function(o) return unroot(mtype[o]) or (getmetatable(o) or {}).__name end,
}, {
  __add=table.append_unique,
--  __name = 'type',
  __pow=function(self, f) return is.callable(f) and (self+f) or self end,
  __call=function(self, t)
    if type(t)=='nil' then return 'nil' end
      local rv
      instance(o)
      for _,f in ipairs(self) do
        rv=f(t)
        if rv then return rv end
      end return nil end,})