require "compat53"

local falsy = {
  [0]=true,
  ["0"]=true,
  ["false"]=true,
  [""]=true,
  [false]=true,
}

local _toboolean = toboolean or function(x) return x and true or false end
toboolean = function(x)
  if type(x)=='table' then
    local tb = (getmetatable(x) or {}).__toboolean
    if type(tb)=='function' then return tb(x) end
  end
  if falsy[x] or type(x)=='nil' or (type(x)=='table' and type(next(x))=='nil') or falsy[tostring(x):lower()] then
    return false
  end
  return _toboolean(x)
end

return toboolean
