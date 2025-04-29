require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
require "meta.module"

local loader = require "meta.loader"
local meta = loader "meta"

if package.loaded.luassert then
  local ok = meta and meta.assert
  if ok then ok() end
end
return meta