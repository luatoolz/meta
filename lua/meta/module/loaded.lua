require "meta.string"
local mcache = require 'meta.mcache'
--local sub = require 'meta.module.sub'
local chain = require 'meta.module.chain'
local toindex = require 'meta.is.toindex'
local rev, instance, type =
  require 'meta.module.rev',
  require 'meta.module.instance',
  require 'meta.module.type'

local this = mcache.mloaded

-- mcache.loaded['t.env']=t.env
-- k is type name
-- v is object
return this/{
init=function() return package.loaded end,
put=function(self, k, v)
print(' loaded.put', k, type(v))
  rev[k]=v
  if v and chain[k] and toindex(v) then
--    self[no.sub(k)]=k
--    k=no.sub(k)
--    self[v]=v
    instance[k]=v
    type[k]=v
--    mcache.fqmn[k]=v
--    mcache.object[k]=k
  end end,
get=function(self, k) if type(k)=='string' and k~='' then
--  if type(k)~='string' then
--    return self[k]
--  end
--  k=rev[k]
print(' loaded.get', k, rev[k])
  return k and package.loaded[rev[k]]
  end end,}