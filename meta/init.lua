require "compat53"
local pkg = select(1, ...)
local loader = require(pkg .. ".loader")
return loader(pkg)
