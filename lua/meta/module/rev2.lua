require "meta.string"
local mcache = require 'meta.mcache'
local sub = require 'meta.module.sub'
local queue = require 'meta.module.iqueue'
local this = mcache.reversed

return this/{
init = function()
--  for k,v in pairs(package.loaded) do
--    if k=='meta.iter' or k=='meta/iter' then print('  FOUND', k, type(v)) end
--  end
  return package.loaded
end,
call  = function(self, k)
  while #queue>0 do
    local i = table.remove(queue)
    print(' dequeue', 'in rev', #queue, i)
    this[i]=true
--    print(' result', i, this[i], this[sub(i)])
  end
  this[k]=true
--  print(' current test', k, this[k], this[sub(k)])
--  return this[k]
  return self[sub(k)]
end,
get   = function(self, k) if type(k)=='string' and k~='' then
--  this[k]=true
  this(k)
  local id = sub(k)
--  return self[id] or id
  return self[id]

--  local rv = self[sub(k)] or k
--  return package.loaded[rv] and rv

--  local a,b = sub(k), self[sub(k)]

--  if package.loaded[a] then print(' rev found', a); return a end
--  if package.loaded[b] then print(' rev found', b); return b end
--  if package.loaded[k] then print(' rev found', k); return k end
--  print(' rev not found', k)
end return nil end,
put   = function(self, k, _) if type(k)=='string' and k~='' then
  local normalized = sub(k)
  local v = self[normalized]
  if (not v) then
    if type(package.loaded[k])~='nil' then
      print(' rev save', k, v, normalized)
      self[normalized] = k
--    elseif type(package.loaded[normalized])~='nil' then
--      print(' rev save2', k, v, normalized)
--      self[normalized] = normalized
--    else
--      print(' rev not loaded', k)
    end
--[[
    if package.loaded[v] or package.loaded[k] or package.loaded[normalized] then
      self[normalized] = k
    else
      print(' no package.loaded for ', k, v, normalized, type(package.loaded['meta.iter']))
    end
--]]
--    if package.loaded[normalized] then self[normalized]=normalized end
--    if package.loaded[k] then self[sub(k)]=k; return end

--  else
--    print(' already in db: ', v)
  end
end end,
}