local index = require 'meta.mt.i'
return function(self, i) if type(self)=='table' and type(i)=='number' then
  return rawget(self, index(self, i))
end end