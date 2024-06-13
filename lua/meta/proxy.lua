local index = {}

local mt = {
  __index = function(self, key)
    return index[self][key]
  end}

return function(o)
  if type(o)=='table' then
    local t = {}
    index[t]=o
    return setmetatable(t, mt)
  end
end
