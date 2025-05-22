--[[
-- object name cache, full path

-- self index for all items

-- first seen module path = object name
--]]

require "meta.string"
local mcache  = require 'meta.mcache'
local sub     = require 'meta.module.sub'
local chain   = require 'meta.module.chain'
local is      = require 'meta.is'
local this    = mcache.instance

-- k is type name
-- v is object
return this ^ {
call=function(self, k) return this[k] end,
get=function(self, k) return self[k] end,
put=function(self, k, v)
  if type(k)=='string' and chain[sub(k)] and is.toindex(v) then
  if (not self[v]) then self[v]=sub(k)
end end end}