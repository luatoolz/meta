local pkg = ...
local loader = require "meta.loader"

return setmetatable({},{
__call=function(_, self, key)
  if type(self)~='table' then return pkg:error('source object required', type(self), key or 'nil') end
  return key and loader(self)[key]
end,
})