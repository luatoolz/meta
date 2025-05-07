local sub = require 'meta.table.sub'
return function(self, ii) if type(self)=='table' and type(ii)=='table' and (type(next(ii))=='nil' or type(ii[1])=='number') then
  local i,j = ii[1] or 1, ii[2] or #self
  if type(i)=='number' then return sub(self, i, j) end
end return nil end