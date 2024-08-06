require "meta.table"
local is = require "meta.is"
return setmetatable({}, {
  __call = function(self, it) return is.similar({}, it) end,
  __index = function(self, it) return table[it] end,
})
