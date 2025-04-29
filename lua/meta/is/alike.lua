require "meta.gmt"
local complex={['table']=true,['userdata']=true}
return function(a,b)
  if type(a)~=type(b) or type(a)=='nil' then return nil end
  if not complex[type(a)] then return rawequal(a,b) and true or nil end
  local ga,gb = getmetatable(a), getmetatable(b)
  local gga, ggb = ga or {}, gb or {}
  if ga and gb and rawequal(gga.__index, ggb.__index) and
    gga.__name==ggb.__name then return true end
  if not rawequal(ga, gb) then return nil end
  if ga or type(a)=='table' then return true end
end