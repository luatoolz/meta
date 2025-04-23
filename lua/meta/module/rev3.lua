require "meta.string"
local mcache = require 'meta.mcache'
local sub = require 'meta.module.sub'
local this = mcache.reversed

return this/{
init = function()
  return package.loaded
end,
call  = function(self, k)
  return this[k]
end,
get   = function(self, k) if type(k)=='string' and k~='' then
  local id = sub(k)
  if not self[id] then
    this[k]=true
  end
  return self[id]
end return nil end,
put   = function(self, k, _) if type(k)=='string' and k~='' then
  local normalized = sub(k)
  local v = self[normalized]
  if (not v) then
    if type(package.loaded[k])~='nil' then
      print(' rev save', k, v, normalized)
      self[normalized] = k
    elseif type(package.loaded[normalized])~='nil' then
      print(' rev save2', k, v, normalized)
      self[normalized] = normalized
    end
  end
end end,
}