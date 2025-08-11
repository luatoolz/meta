require 'meta.math'
local call = require 'meta.call'
return function(self, tt, key, ...) if type(self)=='table' and type(tt)=='table' and type(key)~='nil' then
    local f = tt and tt[key]
    return f and call(f, self, ...)
--    return f and f(self, ...)
  end return nil end