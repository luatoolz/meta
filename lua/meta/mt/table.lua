require 'meta.table'
return function(self, k)
  if type(self)=='table' and type(k)~='string' then
    return table.index(self, k) or table.interval(self, k)
  end end