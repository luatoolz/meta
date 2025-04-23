require "meta.table"
local croot, req =
  'meta.mcache.root',
  require 'meta.mt.require'
local meta, root =
  req('meta'), nil
local module, loader
return setmetatable({},{
__call=function(self, ...)
  if select('#', ...)==0 then
    root=root or package.loaded[croot] or require(croot)
--    no=no or package.loaded['meta.no'] or require('meta.no')
    module=module or require 'meta.module'
    loader=loader or package.loaded['meta.loader'] or require('meta.loader')
    return root
  end
  return (root or meta)(...)
end,
__index=function(self, k)
  return self(k)
end,
})