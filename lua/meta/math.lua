require "compat53"

local math_floor = math.floor
local _time = ngx and ngx.time or os.time

math.randomseed(_time())

if not math.round then
  function math.round(x)
	  return math_floor(tonumber(x)+0.5)
  end
end

assert(tonumber)
local _tonumber = tonumber
tonumber = function(x, base)
  if not base and type(x)=='table' and type((getmetatable(x) or {}).__tonumber)=='function' then
    return getmetatable(x).__tonumber(x)
  end
  return _tonumber(x, base)
end
