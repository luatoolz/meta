require "compat53"
require "meta.gmt"

if not math.round then
  function math.round(x)
	  return type(x)=='number' and math.floor(x+0.5) or nil
  end
end

if not math.round10 then
  function math.round10(it, decimals)
    if type(it)~='string' then return it end
    if (not decimals) then return math.round(it) end
    local multiplier = 10 ^ decimals
    local left = it%1
    local int = it-left
    return int + math.round(left * multiplier) / multiplier
  end
end

math.randomseed(os.time())