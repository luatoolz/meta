require "meta.string"
local mcache = require 'meta.mcache'
local sub = require 'meta.module.sub'
local chain = require 'meta.module.chain'
local toindex = require 'meta.is.toindex'
local this = mcache.type

-- k is type name
-- v is object instance
return this/{
init = function() return package.loaded end,
try=function(v) return v, v and getmetatable(v) end,
normalize=sub,
put=function(self, k, v)
  k=sub(k)
  if type(k)=='string' and chain[k] and toindex[v] then
--    k = sub(k):gsub('^[^/]+%/','')
    if (not self[v]) or self[v]~=k then self[v]=k end
    local g = getmetatable(v)
    if g and ((not self[g]) or self[g]~=k) then self[g]=k end
    end end,}