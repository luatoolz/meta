local wrapper=assert(require "meta.wrapper")
local is=require "meta.is"
return wrapper('testdata/files') ^ function(...) return ... end
