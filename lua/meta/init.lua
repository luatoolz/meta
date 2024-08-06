require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"
require "meta.no"
local pkg = ...
local loader = require "meta.loader"
return loader(pkg) ^ pkg
