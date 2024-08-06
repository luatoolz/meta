require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"
local pkg = ...
local no = require "meta.no"
local loader = require "meta.loader"
return loader(pkg) ^ pkg
