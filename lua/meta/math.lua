require "compat53"

local getmetatable = debug and debug.getmetatable or getmetatable

local math_floor = math.floor

if not math.round then
  function math.round(x) x=tonumber(x)
	  return type(x)=='number' and math_floor(x+0.5) or nil
  end
end

assert(tonumber)
local _tonumber = tonumber
tonumber = function(x, base)
  if type(x)=='number' then return x end
  if type(x)=='table' and not getmetatable(x) then
    local it = ipairs(x)
    it=it(x,0)
    if type(it)=='number' then return #x end
    return
  end
  if (type(x)=='table' or type(x)=='userdata') and getmetatable(x) then
    local mt=getmetatable(x)
    local tn=mt.__tonumber or mt.__len
    if type(tn)=='function' then return tn(x) end
    return
  end
  return _tonumber(x, base)
end
