local is=require "meta.is"
local found
return function(o)
  found=found or package.loaded['meta.module'] or package.loaded['meta/module']
  return (((type(o)=='table' and getmetatable(o)) and is.callable(found)) and found(o)) and true or nil
  end