require 'meta.string'
local checker = require 'meta.checker'
return checker({number=function(...) return ... end, string=string.matcher('^(%*[nal]).*')}, type)