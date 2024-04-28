local loader = require "meta.loader"
local x = loader(select(1, ...))
assert(x)
return x
