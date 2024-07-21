require "meta"
return function(a, b)
  if type(a)~='table' and type(b)~='table' then return a==b end
  if type(a)=='table' and type(b)=='table' then return table.equal(a, b) end
  if type(b)=='table' then a,b=b,a end
  if type(a)=='table' and getmetatable(a) then
    local mts = getmetatable(a)
    if type(b)=='number' and mts.__tonumber then return tonumber(a)==b end
    if type(b)=='string' then return tostring(a)==b end
    if type(b)=='boolean' then return toboolean(a)==b end
  end
  return false
end
