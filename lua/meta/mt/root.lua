require "meta.table"
local croot, req =
  'meta.cache.root',
  require 'meta.mt.require'
local meta, root =
  req('meta')

return function(...)
  if select('#', ...)==0 then
    root=root or package.loaded[croot] or require(croot)
    return root
  end
  return (root or meta)(...)
end