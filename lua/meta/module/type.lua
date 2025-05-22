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
local is      = require 'meta.is'
local this    = mcache.type

-- k is type name
-- v is object instance
return this ^ {
call = function(self, v) return this[v] end,
get=function(self, v) return self[getmetatable(v)] end,
put=function(self, k, v)
  if is.string(k) and chain(sub(k)) and is.toindex(v) and getmetatable(v) and not self[getmetatable(v)] then
    k=sub(k)
    local g = getmetatable(v)
    if g then
      if not self[g] then self[g]=k end
    else
      if not self[v] then self[v]=k end
    end
  end
end,}