require 'meta.gmt'
return function(self, it) if type(self)=='table' and type(it)~='nil' then
  local rv = setmetatable({},getmetatable(self))
  for i,v in ipairs(self) do rv[#rv+1]=v end
  rv[#rv+1]=it
  return rv
end end