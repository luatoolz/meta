local call  = require 'meta.call'
local mt = require 'meta.gmt'
return function(self, k, ...) if type(self)=='table' and type(k)=='string' and k~='' then
  return call(((mt(self).__computable or {})[k]), self, ...) end return nil end