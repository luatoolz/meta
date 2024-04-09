require "compat53"
return function(fn, o)
  assert(type(fn)=='function' or (type(fn)=='table' and type((getmetatable(fn) or {}).__call)=='function')
  return setmetatable(o or {}, {
    __index = function(t, k)
      local val = fn(k)
      t[k] = val
      return val
    end,
    __call  = function(t, k)
      return t[k]
    end
  })
end
