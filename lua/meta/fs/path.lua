require 'meta.table'
local unpack  = table.unpack
--local iter    = require 'meta.iter'
local meta    = require 'meta.lazy'
local fs      = require 'meta.fs'

local is, fn, mt = meta({'is', 'fn', 'mt'})
local _,_,_ = fn[{'n', 'noop','null','args','tuple'}],
              is[{'fs','callable','file','dir','path','toindex','like','empty'}],
              mt[{'computed','setcomputed', 'concat', 'tostring'}]

local args    = unpack(fn[{'args'}])
local add     = mt.add

local path = {}
return setmetatable(path, {
__computable=setmetatable({},{__index=fs}),

__add       = function(self, p) if type(self)=='table' and #self==0 and is.fs.abspath(p) then self[0]='' end; return add(self, p) end,
__call      = function(self, ...) return setmetatable({}, getmetatable(self))+args(...) end,
__concat    = mt.concat,
__name      = 'fs.path',
__id        = tostring,
__index     = mt.computed,
__newindex  = mt.setcomputed,
__eq        = function(a, b) return type(a)~='nil' and is.like(path,a,b) and tostring(a)==tostring(b) end,
__le        = function(a, b) return tostring(a) <= tostring(b) end,
__lt        = function(a, b) return tostring(a) < tostring(b) end,
__sep       = '/',
__tostring  = mt.tostring,
__unm       = function(self) return (self.isfile and self.rm) or (self.isdir and self.rmtree) or nil end,
})