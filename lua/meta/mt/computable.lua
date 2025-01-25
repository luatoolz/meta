local xpcall = require "meta.xpcall"
return function(self, t, key, ...)
  if type(t)=='nil' or (type(t)=='table' and not next(t)) or type(key)=='nil' then return nil end
  return xpcall(rawget(t, key), nil, self, ...)
  end