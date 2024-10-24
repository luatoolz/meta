require "meta.gmt"
local complex={['table']=true,['userdata']=true}
return function(a,b)
  if type(a)~=type(b) or type(a)=='nil' then return end
  if not complex[type(a)] then return rawequal(a,b) and true or nil end
  if getmetatable(a) and getmetatable(b) and getmetatable(a).__name==getmetatable(a).__name then return true end
  if not rawequal(getmetatable(a), getmetatable(b)) then return end
  if getmetatable(a) or type(a)=='table' then return true end
  end