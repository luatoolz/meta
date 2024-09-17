local pkg = (...)
local wrapper=assert(require "meta.wrapper")
return wrapper('testdata/init3', pkg) ^ type