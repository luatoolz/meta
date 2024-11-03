local pkg = ...
local mod = require "meta.loader"

return function(self, key)
  if type(self)~='table' then return nil, '%s: source object required: %s key=%s' % {pkg, type(self), key or 'nil'} end
  return key and mod(self)[key]
  end