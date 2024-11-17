require "meta.table"
local mt, loader, pkg =
  require "meta.mt.mt",
  require "meta.mt.loader",
  ...
local _ = pkg

return setmetatable({},{
__call=function(_, ...) return mt(...) end,
__index=loader,
})