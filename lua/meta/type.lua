require "meta.table"
local sub     = require 'meta.module.sub'
local chain   = require 'meta.module.chain'
local mtype   = require "meta.module.type"
local is      = require 'meta.is'
local mt      = require 'meta.gmt'

return setmetatable({
  function(o)
    local k = mtype[o]
    return (type(k)=='string' and chain[k]) and sub(k):gsub('^[^/.]+[%.%/]?','') or mt(o).__name
  end,
}, {
  __add   = table.append_unique,
  __sub   = table.delete,
  __name  = 'type',
  __pow   = function(self, f) return is.callable(f) and (self+f) or self end,
  __call  = function(self, o)
    if is.toindex(o) then
      local rv
      for _,f in ipairs(self) do
        rv=f(o)
        if rv then return rv end
      end
      return nil
    end
  end,
})