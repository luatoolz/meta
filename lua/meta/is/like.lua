require "meta.gmt"
local checker = require 'meta.checker'
local complex=checker({['table']=true,['userdata']=true},type)
return function(a,b)
  return (type(a)~='nil' and type(a)==type(b) and ((not complex[a]) or getmetatable(a)==getmetatable(b))) and true or nil
end