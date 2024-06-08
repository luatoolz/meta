require "compat53"

return function(fn, key_normalize, o)
  assert(type(fn)=='function' or (type(fn)=='table' and type((getmetatable(fn) or {}).__call)=='function'))
  assert(type(key_normalize)=='nil' or type(key_normalize)=='function' or (type(key_normalize)=='table' and type((getmetatable(key_normalize) or {}).__call)=='function'))
    return setmetatable(o or {}, {
      __newindex = function(t, k, v)
        if type(key_normalize)~='nil' then k=key_normalize(k) end
        rawset(t, k, v)
      end,
      __index = function(t, k)
        if type(key_normalize)~='nil' then k=key_normalize(k) end
        return rawget(t, k) or rawget(rawset(t, k, fn(k)), k)
      end,
      __call  = function(t, k, v)
        if type(key_normalize)~='nil' then k=key_normalize(k) end
        if v and not rawget(t, k) then rawset(t, k, v) end
        return t[k]
      end
    })
end
