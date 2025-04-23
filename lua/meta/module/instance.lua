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
call=function(self, k) return this[k] end,
get=function(self, k)
  if toindex[k] then return self[k] end
  if type(k)=='string' then
    return rev[k]
  end
end,
put=function(self, k, v)
  local orig = k
  if v==true then v=package.loaded[rev[k]] end
  k=sub(k)
  if chain[k] and toindex[v] then
    mtype[k]=v
    if (not self[v]) or self[v]~=k then
      print(' PUT', orig, k, chain[orig])
      self[v]=k
    end
  end
end}