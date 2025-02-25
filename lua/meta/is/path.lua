require 'meta.gmt'
local path
require "meta.is"
return function(f)
  path=path or package.loaded['meta.path'] or require 'meta.path'
  if type(f)=='nil' or f=='' or f=='.' then return end
  return (type(f)=='table' or type(f)=='userdata') and getmetatable(f) and rawequal(getmetatable(path),getmetatable(f))
  end