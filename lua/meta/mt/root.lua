require "meta.table"
local croot, req =
  'meta.mcache.root',
  require 'meta.mt.require'
local meta, root =
  req('meta')

return setmetatable({},{
__call=function(self, ...)
  if select('#', ...)==0 then
    root=root or package.loaded[croot] or require(croot)
    return root
  end
  return (root or meta)(...)
end,
__index=function(self, k)
  return self(k)
end,
})