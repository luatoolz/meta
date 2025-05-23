require 'compat53'
if debug then
  if getmetatable~=debug.getmetatable then getmetatable=debug.getmetatable end
  if setmetatable~=debug.setmetatable then setmetatable=debug.setmetatable end
end
return function(x, k) return type(k)=='nil' and (getmetatable(x) or {}) or (getmetatable(x) or {})[k] end