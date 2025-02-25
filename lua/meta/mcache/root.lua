require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"

local mcache, join = require "meta.mcache", string.slash:joiner()
local module
-- = mcache.module

return mcache.root/{
ordered = true,
revordered = true,
normalize=string.matcher('^[^/.]+'),
try=string.matcher('^[^/.]+'),
get=function(self, k)
  if type(k)=='number' then return self[k] end
  local m=string.matcher('^[^/.]+')
  k=m(k)
  return self[k] and k
end,
call=function(self, ...)
  if not mcache.normalize.module then require "meta.module" end
--  module=module or package.loaded['meta.module'] or require 'meta.module'
  module = module or mcache.module
  local rel=join(...):gsub(string.mdot, string.slash)
  local path=rel
  local checked=mcache.root[path]
  if checked then
    local rv = module(path)
    if rv then rel=rv.rel end
    rv=rv and rv.ok and rv.load
    if type(rv)~='nil' then return rv end
  end
  rel=rel or join(...)
  for _,parent in ipairs(self) do
    if parent~=checked then
      path = join(parent, rel)
      if mcache.loaded[path] then return mcache.loaded[path] end
      local rv = module(path)
      rv=rv and rv.ok and rv.load
      if type(rv)~='nil' then return rv end
    end
  end
end} + 'meta'