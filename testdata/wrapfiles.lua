local pkg = (...)
local wrapper=assert(require "meta.wrapper")
local is=require "meta.is"
local _ = is
return wrapper('testdata/files', pkg) ^ function(...) return ... end
