require "compat53"
local packageName, _ = ...
local loader = require(packageName .. ".loader")
return loader(packageName)
