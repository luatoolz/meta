require 'compat53'
if debug then
  if getmetatable~=debug.getmetatable then getmetatable=debug.getmetatable end
  if setmetatable~=debug.setmetatable then setmetatable=debug.setmetatable end
end
return function(x) return getmetatable(x) or {} end