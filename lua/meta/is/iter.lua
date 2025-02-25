require 'meta.gmt'
local iter
return function(x)
  iter=iter or require 'meta.iter'
  return x and rawequal(getmetatable(iter),getmetatable(x)) or nil end