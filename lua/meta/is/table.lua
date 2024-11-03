require "meta.table"
local t=getmetatable(table())
return setmetatable({}, {
  __call = function(self, it) return type(it)=='table' and (type(getmetatable(it))=='nil' or rawequal(getmetatable(it),t)) end,
  __index = function(self, it) return table[it] end,
})