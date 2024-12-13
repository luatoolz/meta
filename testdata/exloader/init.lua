local meta = require "meta"
return meta.factory({},{
__postindex=function(self, k)
  if k=='ok' then return 'postindex' end
end,})
--[[
setmetatable({},{
__postindex=function(self, k)
  if k=='ok' then return 'postindex' end
end,
__index=meta.mt.factory,
})--]]