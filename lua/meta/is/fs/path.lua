require 'meta.gmt'
local path
return function(f)
  path=path or require('meta.fs.path')
  if type(f)=='nil' or f=='' or f=='.' then return end
  return (type(f)=='table' or type(f)=='userdata') and getmetatable(f) and rawequal(getmetatable(path),getmetatable(f))
  end