require 'meta.gmt'
local preserve = require 'meta.table.preserve'
return function(self, ii) if type(self)=='table' and type(ii)=='table' and (not getmetatable(ii)) and (type(next(ii))~='nil' and type(ii[1])~='number') then
local rk,rv = preserve(self, {}),{}
for i,k in ipairs(ii) do local v=self[k]; rv[i]=v; rk[k]=v end
return rk, table.unpack(rv, 1, #ii)
end return nil end