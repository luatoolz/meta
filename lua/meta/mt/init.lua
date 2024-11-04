require "meta.table"
local mt, req, pkg =
  require "meta.mt.mt",
  require "meta.mt.require",
  ...

return setmetatable({},{
__call=function(_, ...) return mt(...) end,
__index=req(pkg),
})