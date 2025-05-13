--[[
-- typename cache, full path

-- getmetatable index for table,userdata
-- self index         for function, CFunction

-- first seen module path = object type name
--]]

require "meta.string"
local mcache  = require 'meta.mcache'
local sub     = require 'meta.module.sub'
local chain   = require 'meta.module.chain'
local toindex = require 'meta.is.toindex'
local this    = mcache.type

-- k is type name
-- v is object instance
return this ^ {
init = function() return package.loaded end,
call = function(self, v) return this[v] end,
get=function(self, v) return self[getmetatable(v)] end,
put=function(self, k, v)
  k=sub(k)
  if type(k)=='string' and chain[k] and toindex(v) and not self[getmetatable(v)] then
    local g = getmetatable(v)
    if g then
      if not self[g] then self[g]=k end
    else
      if not self[v] then self[v]=k end
    end
  end
end,}