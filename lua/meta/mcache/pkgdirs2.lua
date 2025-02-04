require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"

local mcache = require "meta.mcache"
local co = require 'meta.call'
local iter = require 'meta.iter'
local pkgdir = require 'meta.pkgdir'

return mcache.pkgdirs2/{
init = function() local pkgdirs = ((table() .. package.path:gmatch('[^;]+')) .. package.cpath:gmatch('[^;]+')) * pkgdir
  return co.wrap(function()
    for pkg in iter(pkgdirs) do
      for mod, it in iter(pkg) do co.yield(tostring(it), tostring(mod)) end
    end
  end)
end,
ordered=true,
put=function(self, k, v)
  if type(self[k])~='table' then
    self[k] = {}
    table.append_unique(self, k)
  end
  table.append_unique(self[k], v)
end,
}