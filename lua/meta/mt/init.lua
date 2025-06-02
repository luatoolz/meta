require "meta.table"
local mt  = require "meta.mt.mt"
local pkg = require "meta.pkg"

return setmetatable({},{
__call=function(_, ...) return mt(...) end,
__index=function(self, k) return pkg(self, k) end,
})