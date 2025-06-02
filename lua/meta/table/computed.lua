local call  = require 'meta.call'
local mt    = require 'meta.gmt'
local save  = require 'meta.table.save'
return function(self, k, ...) if type(self)=='table' and type(k)=='string' and k~='' then
  return save(self, k, call(((mt(self).__computed or {})[k]), self, ...)) end return nil end