require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"
local no=require "meta.no"
local pkg = (...) or 'meta'
local loader = require "meta.loader"
local meta = loader(pkg)
--if package.loaded['busted'] then
  meta:assert(no.asserted)
--end
return meta ^ pkg
