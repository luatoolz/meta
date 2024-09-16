local wrapper=assert(require "meta.wrapper")
local is=require "meta.is"
local _ = is
return wrapper('testdata/files') ^ function(...) return ... end
