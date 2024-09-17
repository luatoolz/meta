require "compat53"
require "luassert"

local loader = require "meta.loader"
local no = require "meta.no"
local is = require "meta.is"
local cache = require "meta.cache"

local function asserts(to)
  no.parse(to)
  for k,v in pairs(loader(to .. '.assert', true) or {}) do
    no.asserts(k, table.unpack(v), is[k])
  end
end

return function(to)
  if to then no.track(to) end
  if package.loaded['busted'] then
    if to then
      asserts(to)
    else
      for _,parent in pairs(cache.roots) do asserts(parent) end
    end
  end
  return assert
end
