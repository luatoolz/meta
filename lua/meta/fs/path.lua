require 'meta.table'
local unpack = table.unpack
local meta = require 'meta.lazy'
local fs    = require 'meta.fs'

local is, fn, mt = meta({'is', 'fn', 'mt'})
local _,_,_ = fn[{'n', 'noop','null','args','tuple'}],
              is[{'callable','file','dir','path','toindex','like','empty'}],
              mt[{'computed','setcomputed'}]

local args = unpack(fn[{'args'}])
local add = mt.add

return setmetatable({}, {
__computable = fs[{'cwd','attr','lattr','target','rpath','type','exists','badlink','isfile','islink','ispipe','isdir','inode','age','size','rm','isabs','abs', 'lz'}],
__add       = function(self, p) if #self==0 and is.fs.abspath(p) then self[0]='' end; return add(self, p) end,
__call      = function(self, ...) return setmetatable({}, getmetatable(self))+args(...) end,
__concat    = mt.concat,
__eq        = function(a, b) return type(a)~='nil' and is.like(a,b) and tostring(a)==tostring(b) end,
__name      = 'path',
__id        = tostring,
__index     = mt.computed,
__newindex  = mt.setcomputed,
__sep       = '/',
__tostring  = function(self) return getmetatable(self).__sep:join(self[0], self) or '' end,
})