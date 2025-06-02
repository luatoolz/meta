--local pkg = ...
local mod = require "meta.loader"
local mt = require "meta.mt.mt"
local instance = require 'meta.module.instance'
return function(self, key) if self then
  if type(self)=='table' and mt(self).__loader~=false and key and instance[self] then
    local found = mod(self)
    return (found or {})[key]
  end
end end