local mt          = require 'meta.gmt'
local index       = require 'meta.table.index'
local interval    = require 'meta.table.interval'
local select      = require 'meta.table.select'
local save        = require 'meta.table.save'

local computable  = require 'meta.mt.computable'

return function(self, k)
  if type(self)=='table' and type(k)~='nil' then
  return mt(self)[k]

    or index(self, k)
    or interval(self, k)
    or select(self, k)

    or computable(self, mt(self).__computable, k)
    or save(self, k, computable(self, mt(self).__computed, k))
  end return nil end