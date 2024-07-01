require "compat53"
local assert = require "luassert"

local loader = require "meta.loader"
local no = require "meta.no"
local is = require "meta.is"

for k,v in pairs(loader(..., true)) do
	no.asserts(k, table.unpack(v), is[k])
end

return assert
