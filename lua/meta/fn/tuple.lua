require 'meta.table'
local iter = require 'meta.iter'
return function(...)
  local args = table.pack(...)
--[[
  return function(...)
    local rv = {}
    local len = math.max(#args, n())
    for v in iter.args(...) do  end
  end
--]]
  return function(...)
    local rv = {}
    for i=1,#args do rv[i]=type(args[i])~='nil' and args[i] or select(i, ...) end
    return table.unpack(rv)
  end
end