require "compat53"

_ = require "meta.searcher"
local loaders = require "meta.loaders"
local sub = require "meta.sub"
local prequire = require "meta.prequire"
local path = require "meta.path"
local preload = require "meta.preload"

local name = {}

local mt = {}
mt.__tostring = function(self)
  if type(self)=='table' then self=loaders[self] or self end
  if type(self)=='string' then self=sub(self) end
  assert(type(self)=='string' and #self>0, 'need string, got ' .. type(self))
  return self
end
mt.__index = function(self, key)
  assert(type(self)=='table')
  assert(type(key)=='string' or type(key)=='nil', 'want key: string or nil, got ' .. type(key))
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
  if type(m)=='table' then
    if type((getmetatable(m) or {}).__name)=='string' then
      m=(getmetatable(m) or {}).__name
    elseif name[m] then
      m=name[m]
    end
  end
  assert(type(m)=='string' and #m>0, "type(m) should be string, got " .. type(m))
  m=sub(m)
  assert(type(m)=='string' and #m>0)
  _ = path(m)
  local l = loaders[m] or preload(loaders(m, setmetatable({}, mt)), topreload, torecursive)
  if topreload then assert(l==loaders[m]) end
  if not name[l] then name[l]=m end
  return l
end

return setmetatable({}, mt)
