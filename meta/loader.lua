require "compat53"

local loaders = require "meta.loaders"
local sub = require "meta.sub"
local prequire = require "meta.prequire"
local path = require "meta.path"
local preload = require "meta.preload"

local mt = {}
mt.__tostring = function(self)
  if type(self)=='table' then self=loaders[self] or self end
  if type(self)=='string' then self=sub(self) end
  assert(type(self)=='string' and #self>0, 'need string, got ' .. type(self))
  return self
end
mt.__index = function(self, key)
  assert(type(self)=='table')
  local sself = loaders[sub(self)]
  local node = sub(sself, key)
  local loaded, err1, err2
  loaded, err1 = prequire(node)

  if not (loaded or err1==true) then loaded, err2 = self(node) end
  if loaded then rawset(self, key, loaded) end
  if not loaded and (err1 or err2) then error(table.concat({err1, err2}, "\n-------------------------\n")) end
  return loaded
end
mt.__call = function(self, m, topreload, torecursive)
  assert(type(m)=='string' and #m>0, "type(m) should be string, got " .. type(m))
  m=sub(m)
  assert(type(m)=='string' and #m>0)
  _ = path(m)
  return loaders[m] or preload(loaders(m, setmetatable({}, mt)), topreload, torecursive)
end

return setmetatable({}, mt)
