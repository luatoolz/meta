require "compat53"

local ignore = { ['__index']=true }
return function(o, x)
  if o==nil then return nil end
  local rv = {}
  o = getmetatable(o) or o
  if o then
    for k,v in pairs(o) do
      if not rawget(rv,k) and k:match("^__") and not ignore[k] then
        rawset(rv, k, rawget(o, k) or o[k])
      end
    end
  end
  if x then
    for k,v in pairs(x) do
      if k:match("^__") then
        rawset(rv, k, rawget(x, k))
      end
    end
  end
  return rv
end
