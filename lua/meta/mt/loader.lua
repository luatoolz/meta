--local pkg = ...
local mod = require "meta.loader"
local mt = require "meta.mt.mt"
local instance = require 'meta.module.instance'
return function(self, key) if self then
--  if type(self)~='table' then return pkg:error('source object required', type(self), key or 'nil') end
--  print(' call mt.loader(%s, %s)' ^ {mt(self).__name, key}, instance(self))
  if type(self)=='table' and mt(self).__loader~=false and key and instance[self] then
    local found = mod(self)
    print(' found[%s]' ^ key, type(found), found)
--    return (mod(self) or {})[key] end
    return (found or {})[key]
  end
end end