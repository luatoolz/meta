require "compat53"
require "meta.gmt"
require "meta.table"
local is = require "meta.is.basic"
--local is = {boolean=function(x) return type(x) == 'boolean' end, table=function(x) return type(x) == 'table' end}
local types={
  ['table']=true,
  ['userdata']=true,
}
return function(self, ...)
  if not types[type(self)] then return nil end
  local args = table {...}
  local meta = (args % is.table)[1]
  local tocreate = (args % is.boolean)[1]
  if not meta then return getmetatable(self) or (tocreate and getmetatable(setmetatable(self, {})) or nil) or (type(tocreate) == 'nil' and {}) or nil end
  local existing = getmetatable(self)
  if not existing then
    setmetatable(self, meta)
  elseif existing ~= meta then
    for k, v in pairs(meta) do if rawget(existing, k) ~= v then rawset(existing, k, v) end end
  end
  return self
end