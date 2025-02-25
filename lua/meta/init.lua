require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
require "meta.no"

local loader = require "meta.loader"
local meta = loader "meta"
if package.loaded.luassert then
  meta:assert()
end
return meta