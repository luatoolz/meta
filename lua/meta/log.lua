require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
local getmetatable=debug and debug.getmetatable or getmetatable

local check={
report=function(it) return type(it)=='boolean' end,
logger=function(it)
  return type(it)=='nil' or type(it)=='function' or
    ((type(it)=='table' or type(it)=='userdata') and
    type((getmetatable(it) or {}).__call)=='function')
end
}

return setmetatable({_={report=false,logger=print}}, {
__pow=function(self, it)
  for k,f in pairs(check) do
    if f(it) then self[k]=it; return it end
  end
end,
__call=function(self, ...) if self.report and self.logger then return self.logger(...) end end,
__index=function(self, k) if check[k] then return self._[k] end end,
__newindex=function(self, k, v) if check[k] and check[k](v) then self._[k]=v end end,
})