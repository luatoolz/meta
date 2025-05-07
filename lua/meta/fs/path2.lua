require 'meta.table'
local iter = require 'meta.iter'
local unpack = table.unpack
local meta = require 'meta.lazy'
local fs    = require 'meta.fs'

local is, fn, mt = meta({'is', 'fn', 'mt'})
local _,_,_ = fn[{'n', 'noop','null','args','tuple'}],
              is[{'callable','file','dir','path','toindex','like','empty'}],
              mt[{'computed','setcomputed'}]

local n, args = unpack(fn[{'n','args'}])

return setmetatable({}, {
__computable = fs[{'cwd','attr','lattr','target','rpath','type','exists','badlink','isfile','islink','ispipe','isdir','inode','age','size','rm','isabs','abs', 'lz'}],
__add       = function(self, p) if type(p)~='nil' then
  if #self==0 and is.fs.abspath(p) then self[0]='' end
  if type(p)=='table' then p=iter.ivalues(p) end
  if type(p)=='table' or type(p)=='function' then for k in iter(p) do _=self+k end end
  if type(p)=='string' then
    if not p:match('^[^/]+$') then return self+p:gmatch('[^/]+') end
    if p=='..' and #self>0 then table.remove(self) end
    if not is.fs.skip(p) then table.insert(self,p) end
end end return self end,
__call      = function(self, ...) return setmetatable({}, getmetatable(self))+args(...) end,
__concat     = function(self, it) return type(it)=='nil' and self or (self(self[{0}])+it) end,
__eq        = function(a, b) return type(a)~='nil' and is.like(a,b) and tostring(a)==tostring(b) end,
__name      = 'path',
__id        = tostring,
__index     = mt.computed,
__newindex  = mt.setcomputed,
__sep       = '/',
__tostring  = function(self) return getmetatable(self).__sep:join(self[0], self) or '' end,
})