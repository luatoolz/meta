local root, save =
  require 'meta.mt.root',
  table.save

return setmetatable({},{
__index=function(self, k)
  if type(k)=='string' and #k>0 then
    return save(self, k, string.matcher(root('matcher', k)))
  end
end,
})