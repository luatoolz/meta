require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"
require "meta.no"
local cache = require "meta.cache"
local typename = cache.typename

local tester = table({
function(o)
  return typename[o] or (type(o)=='table' and getmetatable(o) and typename[getmetatable(o)] or nil)
end,
})

return setmetatable({}, {
  __pow=function(self, f)
    if type(f)=='function' then table.append_unique(tester, f) end
    return self
  end,
  __call=function(self, t)
    if type(t)=='nil' then return 'nil' end
    local rv
    for _,f in ipairs(tester) do
      rv=f(t)
      if rv then return rv end
    end
    return nil
  end,
})
