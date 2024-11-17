local pkg = ...
local mod = require "meta.loader"

return function(self, key)
  if type(self)~='table' then return pkg:error('source object required', type(self), key or 'nil') end
  return key and mod(self)[key]
  end