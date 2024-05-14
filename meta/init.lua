require "compat53"

_ = require "meta.searcher"

local pkg = select(1, ...)
local loader = require(pkg .. ".loader")
return loader(pkg)
