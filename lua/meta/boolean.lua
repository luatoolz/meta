require "compat53"
require 'meta.string'

local falsy = {
  [0]=true,
  ["0"]=true,
  ["false"]=true,
  [""]=true,
  [false]=true,
  ['nil']=true,
}

local _toboolean
local function to_boolean(x)
--  if type(x)=='nil' then return false end
  if type(x)=='table' then
    local tb = (getmetatable(x) or {}).__toboolean
    if type(tb)=='function' then return tb(x) end
    return type(next(x))~='nil'
  end
  if type(x)=='nil' --or (type(x)=='table' and type(next(x))=='nil' or false)
                    or falsy[x] or falsy[string.lower(tostring(x) or '')] then
    return false
  end
  return _toboolean(x)
end
if toboolean~=to_boolean then
  _toboolean = toboolean or function(x) return x and true or false end
  toboolean=to_boolean
end

return toboolean
