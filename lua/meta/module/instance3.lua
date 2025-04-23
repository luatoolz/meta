require "meta.string"
local mcache = require 'meta.mcache'
local sub = require 'meta.module.sub'
local chain = require 'meta.module.chain'
local toindex = require 'meta.is.toindex'
local queue = require 'meta.module.iqueue'
local rev = require 'meta.module.rev'
local mtype = require 'meta.module.type'
local this = mcache.instance

-- k is type name
-- v is object
return this/{
init=function() return package.loaded end,
call=function(self, k)
  return this[k]
end,
get=function(self, k)
--[[
  local v
  local list = {}
  for qk, qv in pairs(queue) do
    list[qk]=qv
  end
  for qk, qv in pairs(list) do
--    v = package.loaded[rev[qk] ] or package.loaded[qk] or package.loaded[sub(qk)]
    if qv then
      this[qk]=true
--      _ = queue - qk
--      queue[qk]=nil
    else
      if toindex[v] then
        this[qk]=true
--      _ = queue - qk
--        queue[qk]=nil
      else
        print(' invalid', qk)
--        print(' invalid', qk, rev[qk], type(package.loaded[qk]), type(package.loaded[rev[qk] ]))
--        queue[qk]=nil
      end
    end
    queue[qk]=nil
  end
--]]
  if toindex[k] then return self[k] end
  if type(k)=='string' then
    return rev[k]
--    k = rev[k] or sub(k)
--    v = package.loaded[rev[k]] or package.loaded[sub(k)]
--    if toindex[v] then this[k]=v; return rev[k] end
  end
end,
put=function(self, k, v)
  local orig = k
--  rev[k]=true
  if v==true then
    v=package.loaded[rev[k]] or package.loaded[k] or package.loaded[sub(k)]
--    print(' instance.put (v==true)', k, v)
  end
--  if v==true then v=package.loaded[rev[k] or k] end
  k=sub(k)
--  if v==true then v=package.loaded[rev[k]] end
  print(' instance.put', k,v,chain[k],toindex[v])
  if k and v then
    if chain[k] then
      if toindex[v] then
        mtype[k]=v
        if (not self[v]) or self[v]~=k then
          print(' PUT', orig, k, chain[orig])
          self[v]=k
        end
      end
    end
  end
end}