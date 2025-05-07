require 'meta.string'
local complex, save =
  require 'meta.is.complex',
  require 'meta.table.save'

return setmetatable({
  __index=function(o) return complex(o) and getmetatable(o) and (type((getmetatable(o) or {}).__index)=='function' or type((getmetatable(o) or {}).__index)=='table') end,
},{
  __call=function(self, o) return complex(o) and type(getmetatable(o))=='table' end,
  __index=function(self, k) return string.null(k) and save(self, k, self/k) end,
  __div=function(self, k) return string.null(k) and function(o) return complex(o) and type((getmetatable(o) or {})[k])~='nil' end end,
})