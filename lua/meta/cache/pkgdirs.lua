require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"

local cache = require "meta.cache"
local is = require "meta.is"

return cache.pkgdirs/{
init=function() return package.path:gmatch('([^?;]*)%?([^;]+)') end,
ordered=true,
put=function(self, v, k)
  if type(k)~='string' or type(v)~='string' or v=='' or (not is.dir(k)) then return end
  if k=='' then k='./' end
  if type(self[k])~='table' then
    self[k]=table{}
    table.append_unique(self, k)
  end
  table.append_unique(self[k], v)
end,
}