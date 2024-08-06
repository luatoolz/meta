require "compat53"

local math_floor = math.floor

if not math.round then
  function math.round(x) x=tonumber(x)
	  return type(x)=='number' and math_floor(x+0.5) or nil
  end
end

assert(tonumber)
local _tonumber = tonumber
tonumber = function(x, base)
  if type(x)=='table' then
    local tn = (getmetatable(x) or {}).__tonumber
    if type(tn)=='function' then return tn(x, base) end
  end
  return _tonumber(x, base)
end
