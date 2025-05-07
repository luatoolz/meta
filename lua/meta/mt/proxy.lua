-- proxy object
local fs, save = require 'meta.fs', require 'meta.table.save'
local this = {}
return setmetatable(this,{
__add=function(self, a) return self._+a end,
__call=function(self, o) return setmetatable({_=o},getmetatable(self)) end,
--  if rawequal(self, this) then return setmetatable({_=o},getmetatable(this)) end end,
__concat=function(self, k) return self._..k end,
__index=function(self, k)
  local callable = fs[k]
  local rv = rawget(self,k); if type(rv)~='nil' then return rv end
  rv = rawget(self._,k); if type(rv)~='nil' then return rv end
  return (callable and save(self, k, callable(self))) end,
--__newindex=function(self, it, v) rawset(self._,it,v) end,
__eq=function(a,b) return a._==b._ end,
__mul=function(self, x) return self._*x end,
__mod=function(self, x) return self._%x end,
__div=function(self, x) return self._/x end,
__sep='/',
__name='fs',
__tostring=function(self) return tostring(self._) end,
__sub=function(self, k) return self._-k end,
})
