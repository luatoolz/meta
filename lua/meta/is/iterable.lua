require 'meta.table'
local is = {
--  table = require 'meta.is.table',
  complex = require 'meta.is.complex',
}
--local function mt(x) return is.complex(x) and getmetatable(x) or {} end
--return function(x) return mt(x).__iter and true or nil end

return function(o)
  if type(o)=='function' then return true end
  if type(o)=='table' and ((not getmetatable(o)) or rawequal(getmetatable(o),getmetatable(table()))) then return true end
  if is.complex(o) then local g = getmetatable(o)
  return g and (g.__pairs or g.__ipairs or g.__iter or g.__next) and true or nil end end