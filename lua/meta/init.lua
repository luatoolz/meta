require "compat53"
assert(require "meta.gmt")
assert(require "meta.math")
assert(require "meta.string")
assert(require "meta.table")
assert(require "meta.no")

local loader = assert(require "meta.loader")
local meta = loader "meta"
if package.loaded.luassert then
  meta:assert()
end
return meta