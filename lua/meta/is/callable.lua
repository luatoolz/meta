require "meta.gmt"
return function(x) return (
      (type(x)=='function' or type(x)=='CFunction') or (
        (type(x)=='table' or type(x)=='userdata') and
        type((getmetatable(x or {}) or {}).__call)=='function'
      )
) and true or nil end