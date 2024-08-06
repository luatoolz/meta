return function(a, b)
  if type(a)~='table' or type(b)~='table' then return false end
  local aseen, bseen = {}, {}
  local i=0
  for _,k in pairs(a) do i=i+1; aseen[k]=true end
  for k,_ in pairs(b) do i=i-1; bseen[k]=true end
  if i~=0 then return false end
  for k,_ in pairs(aseen) do if not bseen[k] then return false end end
  for k,_ in pairs(bseen) do if not aseen[k] then return false end end
  return true
end