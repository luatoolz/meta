local found
return function(o)
  found=found or package.loaded['meta.loader'] or package.loaded['meta/loader']
  return ((type(o)=='table' and getmetatable(o)) and found or {})[o] and true
  end