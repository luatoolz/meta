require "meta.string"
local mcache  = require 'meta.mcache'
local chain   = require 'meta.module.chain'
local toindex = require 'meta.is.toindex'
local save    = require 'meta.table.save'
local ok      = function(x) if toindex(x) then return x end end
local this    = mcache.mloaded

-- k is type name
-- v is object
return this ^ {
init=function() return package.loaded end,
call=function(self, k) return self[k] end,
put=function(self, k, v)
if chain[k] and toindex(v) then self[k]=v end end,
get=function(self, k) if type(k)=='string' and k~='' then
  return self[k] or save(self, k, ok(package.loaded[k])) end end,}