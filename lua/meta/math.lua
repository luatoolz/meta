require "compat53"

local _time = ngx and ngx.time or os.time

math.randomseed(_time())

--local floor = math.floor
if not math.round then
  function math.round(x)
	  return math.floor( tonumber(x) + 0.5)
  end
end

assert(tonumber)
local _tonumber = tonumber
tonumber = function(x)
  if type(x)=='table' and type((getmetatable(x) or {}).__tonumber)=='function' then
    return getmetatable(x).__tonumber(x)
  end
  return _tonumber(x)
end
