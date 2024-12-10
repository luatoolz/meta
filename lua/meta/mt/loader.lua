local pkg = ...
local mod = require "meta.loader"
local mt = require "meta.mt.mt"
return function(self, key)
  if type(self)~='table' then return pkg:error('source object required', type(self), key or 'nil') end
  if type(self)=='table' and mt(self).__loader==false then return end
  if key then return (mod(self) or {})[key] end
  end