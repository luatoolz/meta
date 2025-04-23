require 'meta.math'
local call = require 'meta.call'
return function(self, tt, key, ...)
  if type(tt)=='nil' or (type(tt)=='table' and not next(tt)) or type(key)=='nil' then return nil end
--  return call(rawget(tt, key), self, ...) or error('no computable' / self / key)
--  return call:onfail('computed failed[ %s.%s ]'^{self,key})(rawget(tt, key), self, ...)
    return call(rawget(tt, key), self, ...)
  end