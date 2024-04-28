require "compat53"

local use_debug=false
local g = use_debug and ((debug or {}).getmetatable) or getmetatable

if (use_debug) and ((debug or {}).getmetatable) or false then
  return function(t, alt) return debug.getmetatable and (debug.getmetatable(t) or alt) or (getmetatable(t or {}) or alt) end
else
  return function(t, alt) return g(t or {}) or alt end
end
