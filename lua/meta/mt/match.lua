require 'meta.table'
local load, save =
  require 'meta.module.load',
  table.save

return setmetatable({},{
__index=function(self, k)
  if type(k)=='string' and #k>0 then
    return save(self, k, string.matcher(load('matcher', k)))
  end
end,
})