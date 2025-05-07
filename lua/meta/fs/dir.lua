require 'meta.table'
local iter  = require 'meta.iter'
local path  = require 'meta.fs.path'
local fs    = require 'meta.fs'
local g     = getmetatable(path) or {}
return setmetatable({},{
__add       = g.__add,
__call      = g.__call,
__concat    = function(self, k)
  local r = g.__concat(self, k)
  if r then fs.mkdir(r) end
  return r
end,
__eq        = g.__tostring,
__index     = function(self, k)
  if k==true then return path(self) end
  return g.__index(self, k)
end,
__tostring  = g.__tostring,
--__newindex  = function(self,k,v) end,
__id        = g.__id,
__sep       = g.__sep,

__name      = 'dir',
__iter      = function(self, it) return iter(fs.ls(self), it) end,
__div       = table.div,
__mul       = table.map,
__mod       = table.filter,
__unm       = function(self) return fs.rmdir(self) end,})