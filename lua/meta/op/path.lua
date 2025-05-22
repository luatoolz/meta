require 'meta.string'
local mt      = require 'meta.gmt'
local iter    = require 'meta.iter'
local tuple   = require 'meta.tuple'
local is      = require 'meta.is'

local computed, setcomputed, args =
  require "meta.mt.computed",
  require "meta.mt.setcomputed",
  tuple.args

return setmetatable({},{
__add = function(self, p) if type(self)=='table' and type(p)~='nil' then
  if type(p)=='table' then p=iter.ivalues(p) end
  if type(p)=='table' or type(p)=='function' then for k in iter(p) do _=self+k end end
  if type(p)=='string' then
    if not p:match('^[^/]+$') then return self+p:gmatch('[^/]+') end
    if p=='..' and #self>0 then table.remove(self) end
    if not p:match('^%.*$') then table.insert(self,p) end
    end end return self end,

__call      = function(self, ...) return setmetatable({}, getmetatable(self))+args(...) end,

__concat = function(self, it) if type(self)=='table' then
  return type(it)=='nil' and self or
  (setmetatable(self[{0}],getmetatable(self))+it) end end,

__index     = computed,
__newindex  = setcomputed,
__id        = tostring,
__eq        = function(a, b) return type(a)~='nil' and is.like(a,b) and tostring(a)==tostring(b) end,
__le        = function(a, b) return tostring(a) <= tostring(b) end,
__lt        = function(a, b) return tostring(a) < tostring(b) end,
__tostring = function(self) return (mt(self).__sep or string.sep):join(self[0], self) or '' end,
__sep       = '/',
})