require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"

local cache, join = require "meta.cache", string.slash:joiner()
local module = cache.module

return cache.root/{
ordered=true,
normalize=string.matcher('^[^/.]+'),
try=string.matcher('^[^/.]+'),
get=function(self, k)
  if type(k)=='number' then return self[k] end
  local m=string.matcher('^[^/.]+')
  k=m(k)
  return self[k] and k
end,
call=function(self, ...)
  if not cache.normalize.module then require "meta.module" end
  for _,parent in ipairs(self) do
    local path = join(parent, ...)
    path=path and path:gsub(string.mdot, string.slash)
    local rv = module(path)
    rv=rv and rv.ok and rv.load
    if type(rv)~='nil' then return rv end
  end
end} + 'meta'