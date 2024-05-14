require "compat53"

local cache = require "meta.cache"
local conf = cache('conf')

conf.m = '%'
conf.sep = _G.package.config:sub(1,1)
conf.dot = '.'
conf.msep = conf.m .. conf.sep
conf.mdot = conf.m .. conf.dot
return conf
