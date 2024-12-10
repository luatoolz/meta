local pkg = ...
local meta = require "meta"
local mod = require "meta.loader"
local mt = meta.mt

return function(self, key)
  if type(self)~='table' then return pkg:error('source object required', type(self), key or 'nil') end
  if mt(self).__loader~=false then return key and (mod(self) or {})[key] end
  end