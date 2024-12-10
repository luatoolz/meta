local t = require "meta"
return setmetatable({},{
__postindex=function(self, k)
  if k=='ok' then return 'postindex' end
end,
__index=t.mt.factory,
})