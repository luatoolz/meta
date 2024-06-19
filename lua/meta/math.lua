require "compat53"

if ngx then
  math.randomseed(ngx.time())
end

local floor = math.floor
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