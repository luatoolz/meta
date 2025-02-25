local is = require 'meta.is'
local iter = require 'meta.iter'
return function(a, b)
  if is.callable(b) or (getmetatable(b) or {}).__iter then
    b = table() .. iter(b)
  end
  if type(a)~='table' or type(b)~='table' then return false end
  local aseen, bseen = {}, {}
  local i=0
  for _,v in pairs(a) do i=i+1; aseen[v]=true end
  for _,v in pairs(b) do i=i-1; bseen[v]=true end
  if i~=0 then return false end
  for k,_ in pairs(aseen) do if not bseen[k] then return false end end
  for k,_ in pairs(bseen) do if not aseen[k] then return false end end
  return true
end