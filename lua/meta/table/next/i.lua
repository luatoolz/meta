-- function table:ipairs() return table.nexti, self end

-- table.next.int
-- next int
local maxi = require 'meta.table.maxi'
return function(self, cur)
  local i,v = cur
  repeat i = (i or 0)+1; v=self[i]
  until type(v)~='nil' or i>maxi(self)
  if type(i)=='number' and i>maxi(self) then return nil, nil end
  return i,v
end