require "meta.gmt"
local n = require 'meta.fn.n'
local function tolike(a,b)
  return (type(a)~='nil' and type(a)==type(b) and ((type(a)~='table' and type(b)~='userdata') or rawequal(getmetatable(a),getmetatable(b)))) and true or nil
end
return function(x,y,...)
  local rv = tolike(x,y)
  if rv and n(...) then
    for _,v in ipairs({...}) do rv=rv and tolike(x,v); if not rv then break end end
  end
  return rv
end