local index = require 'meta.table.index'
local interval = require 'meta.table.interval'
return function(self, k)
  if type(self)=='table' then
    return index(self, k) or interval(self, k)
  end end