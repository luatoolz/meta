local iter = require 'meta.iter'
local is = require 'meta.is'
local path = require 'meta.path'
--local file = require 'meta.file'
local save = table.save
local _ = save

return setmetatable({},{
__add       = table.append,
__call      = function(self, ...)
  local p = path(...)
  return p.mkdir and setmetatable(p, getmetatable(self))
end,
__concat    = function(self, it)
  if is.number(it) then it=tostring(it) end
  if is.string(it) then return self+it end
  if is.table(it) then it=iter(it) end
  if is.func(it) then for x in it do local _=self+x end end
  return self
end,
__div       = function(self, k) return self(self, k) end,
__eq        = function(a, b) return tostring(a)==tostring(b) end,
--__gc        = function(self) for k in table.keys(self) do self[k]=nil end end,
__index     = function(self, k)
  if type(k)=='number' then return table.index(self, k) end
  if type(k)=='string' then return path(self, k).file end
--  if type(k)=='string' then return save(self, k, path(self, k).file) end
end,
__iter      = function(self) return path(self).files end,
__newindex  = function(self, it, v)
  local p = it and path(self, it).file
--  local p = it and save(self, it, path(self, it).file)
  if type(v)~='nil' then return p and p.writecloser(tostring(v)) end
  if type(v)=='nil' then return self-it end
end,
__mod       = function(self, k)
  if k==is.file then return iter.map(path(self).files) end
  if k==is.dir then return iter.map(path(self).dirs) end
  return path(self)%k
end,
__mul       = function(self, k)
  if k=='files' then return iter.map(path(self).files) end
  if k=='dirs' then return iter.map(path(self).dirs) end
  return path(self)*k
end,
__sub       = function(self, it)
  local function rm(k)
    if is.file(k) then k=k.name end
    return (k and type(k)=='string') and path(self, k).rmitem or nil
  end
  if is.table(it) or is.func(it) then iter.map(it, rm) else rm(it) end
  return self
end,
__tostring  = function(self) return string.join('/', self) end,
__unm       = function(self) return path(self).rmdir end,
})