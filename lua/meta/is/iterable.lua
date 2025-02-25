local is = {
  table = require 'meta.is.table',
  complex = require 'meta.is.complex',
}
local function mt(x) return is.complex(x) and getmetatable(x) or {} end
return function(x) return mt(x).__iter and true or nil end