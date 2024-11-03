local found
return function(o)
  found=found or package.loaded['meta.loader'] or package.loaded['meta/loader']
  return o and found and type(o)=='table' and type(found)=='table' and rawequal(getmetatable(o),getmetatable(found)) and true or nil
  end