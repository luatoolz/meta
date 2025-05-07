-- like string.sub for table
-- todo: boundary control
local preserve = require 'meta.table.preserve'
return function(self,i,j)
  if type(self)~='table' then return nil end
  local rv = preserve(self, {})
  if #self==0 then return rv end
  i=i or 1
  j=j or #self
  if type(i)~='number' or type(j)~='number' then return nil end
  if i==0 then rv[0]=self[0] end
  if i<0 then i=(#self+1)+i end; if i<1 then i=1 end
  if j<0 then j=(#self+1)+j end; if j<1 then j=1 end
  if i>#self then i=#self end
  if j>#self then j=#self end
  while i<=j do
    table.insert(rv, self[i])
    i=i+1
  end
  return rv
end