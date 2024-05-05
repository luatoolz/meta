require "compat53"

local g = ((debug or {}).getmetatable) or getmetatable

if (debug or {}).getmetatable then
  return function(t, alt) return debug.getmetatable and (debug.getmetatable(t) or alt) or (getmetatable(t or {}) or alt) end
else
  return function(t, alt) return g(t or {}) or alt end
end
