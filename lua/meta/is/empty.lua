require 'meta.gmt'
local checker = require 'meta.checker'
return checker({
    ['nil']=true,
    number=function(x) return x==0 end,
    string=function(x) return x=='' or x:match("^%s+$") end,
    table=function(x) return (not getmetatable(x)) and type(next(x))=='nil' end,
  }, type)