require 'meta.table'
local fs      = require 'meta.fs'
local tuple   = require 'meta.tuple'
local is      = require 'meta.is'

local add, concat, computed, setcomputed, tostringer, args =
  require 'meta.mt.add',
  require 'meta.mt.concat',
  require 'meta.mt.computed',
  require 'meta.mt.setcomputed',
  require 'meta.mt.tostring',
  tuple.args

local path = {}
return setmetatable(path, {
__computable=setmetatable({},{__index=fs}),
__add       = function(self, p) if type(self)=='table' and #self==0 and is.fs.abspath(p) then self[0]='' end; return add(self, p) end,
__call      = function(self, ...) return setmetatable({}, getmetatable(self))+args(...) end,
__concat    = concat,
__name      = 'fs.path',
__id        = tostring,
__index     = computed,
__newindex  = setcomputed,
__eq        = function(a, b) return type(a)~='nil' and is.like(path,a,b) and tostring(a)==tostring(b) end,
__le        = function(a, b) return tostring(a) <= tostring(b) end,
__lt        = function(a, b) return tostring(a) < tostring(b) end,
__sep       = '/',
__tostring  = tostringer,
__unm       = function(self) return self.remover end,
})