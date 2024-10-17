require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
local t=getmetatable(table())
return setmetatable({}, {
  __call = function(self, it) return type(it)=='table' and (type(getmetatable(it))=='nil' or rawequal(getmetatable(it),t)) end,
  __index = function(self, it) return table[it] end,
})