require 'compat53'
require 'meta.gmt'
require 'meta.math'
require 'meta.string'
local require, setmetatable, getmetatable, type, tostring =
  require, setmetatable, getmetatable, type, tostring
local concat, insert = table.concat, table.insert
local _, unpack = table.pack or pack, table.unpack or unpack
local save = require 'meta.table.save'

local call = require 'meta.call'
local parts = '[^%.%/]+'
local is = {
  callable = require 'meta.is.callable',
}

return setmetatable({'meta'},{
__sep = string.dot,
__add = function(self, k) if type(k)=='string' and not rawget(self, k) then
    local o = {}; for i=1,#self do insert(o, self[i]) end
    insert(o, k)
    return save(self, k, setmetatable(o, getmetatable(self)))
  end
  return self
end,
__call = function(self, a, ...)
if type(a)=='string' then
print('__call', self, a, ...)
  local path = tostring(self)..'.'..concat({a,...},'.')
--print('__call 2', path)
  return package.loaded[path] or call(require,path)
end
if type(a)=='table' and #a>0 then local rv = {}
print(' lazt.call', type(a), #a)
  for i,k in ipairs(a) do rv[i]=self[k]; print(' lazy.append', i, k);  end
  return unpack(rv, 1, #a)
end end,
__concat = function(self, k) if type(k)=='string' or type(k)=='table' or type(k)=='function' then
--print(' __concat', self)
  local o = self
  if type(k)=='string' then k=k:gmatch(parts) end
  if is.callable(k) then for p in k do o=o+p end; k=nil end
  if type(k)=='table' then for _,p in ipairs(k) do _=o+p end end
  return o
end end,
__div = function(self, k)
  local path = tostring(self)
  if type(k)=='string' and k~='' then path=path .. '.' .. k end
  return path
end,
__mod = function(self, k)
  local path = tostring(self) .. '.' .. k
--print(' _mod ', type(self), tostring(self), k, path)
  return package.loaded[path] or nil
end,
__index = function(self, k) if type(k)=='string' and #k>0 then
  local path = tostring(self) .. '.' .. k
  return package.loaded[path] or call(require,path)
end;end,
__tostring = function(self) return concat(self, (getmetatable(self) or {}).__sep or string.sep) end,
}) .. {'fn','is','matcher','mcache','module','mt','table'}