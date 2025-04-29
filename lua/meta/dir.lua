local iter = require 'meta.iter'
local is = require 'meta.is'
local path = require 'meta.path'
local selector = require 'meta.select'

local this = {}
return setmetatable(this,{
__add       = table.append,
__call      = function(self, d, ...)
  if type(d)=='table' and rawequal(getmetatable(this), getmetatable(d)) then
    local sub = ...
    if not sub then return d end
  end
  local p = path(d, ...).clone
  return p.mkdir and setmetatable(p, getmetatable(this)) or nil
end,
__concat    = function(self, it)
--  if is.number(it) then it=tostring(it) end
  if is.string(it) then return self+it end
  local rv = self
  for x in iter(it) do rv=rv+x end
  return rv
end,
__div       = function(self, k) return self(self, k) end,
__eq        = function(a, b) return tostring(a)==tostring(b) end,
__index     = function(self, k)
  if type(k)=='number' then return table.index(self, k) end
  if type(k)=='table' and not getmetatable(k) then return table.interval(self, k) end
  if type(k)=='string' then return path(self, k).file end
end,
__iter      = function(self, it) return iter(path(self).ls, it)*selector.instance end,
__name      = 'dir',
__newindex  = function(self, it, v)
  local p = it and path(self, it).file
  if type(v)~='nil' then return p and p.writecloser(tostring(v)) end
  if type(v)=='nil' then return self-it end
end,
__mul = table.map,
__mod = table.filter,
__sub       = function(self, it)
  if type(it)=='nil' then return self end
  if type(it)=='string' then it={it} end
  if is.table(it) or is.func(it) then
    iter.each(iter(it), function(k) return path(self,k).rmall end)
  end
  return self
end,
__tostring  = function(self) return string.join('/', self) end,
__unm       = function(self)
  iter.each(iter(self), function(x) return -x end)
  return path(self).rmdir
end,
})