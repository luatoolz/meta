local mcache = require 'meta.mcache'
local save = table.save
local default = {
  preload = false,
  recursive = true,
  inherit = true,
}
return mcache.module_options ^ {
get=function(this, o)
  return this[o] or save(this, o, setmetatable({
    set = setmetatable({},{
      __index = function(setter, k)
        return function(...)
          if select('#', ...)>0 then this[o][k]=(...) end
          return setter
        end
      end,
      __newindex = function(setter, k, v) this[o][k]=v end,
    }),
  },{
    __index = function(self, k) return default[k] end,
  }))
end,
}