require 'meta.gmt'
require 'meta.math'
require 'meta.string'
local require, setmetatable, getmetatable, type, tostring =
  require, setmetatable, getmetatable, type, tostring
local concat, insert = table.concat, table.insert

local call = require 'meta.call'
local parts = '[^%.]+'

return setmetatable({},{
__call = function(self, name) if type(name)=='string' then
  local rv = {}
  for v in name:gmatch(parts) do insert(rv, v) end
  return #rv>0 and setmetatable(rv, getmetatable(self)) or nil
end end,
__div = function(self, k)
  local path = tostring(self)
  if type(k)=='string' and k~='' then path=path .. '.' .. k end
  return path
end,
__mod = function(self, k)
  return package.loaded[self/k] or nil
end,
__concat = function(self, k)
  rawset(self, k, self(tostring(self) .. '.' .. k))
  return self[k]
end,
__index = function(self, k) if type(k)=='string' and #k>0 then
  local path = tostring(self) .. '.' .. k
  return package.loaded[path] or call(require,path)
end end,
__tostring = function(self)
  return concat(self, '.')
end,})