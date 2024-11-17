require "compat53"
require "meta.gmt"

if not math.round then
  function math.round(x)
	  return type(x)=='number' and math.floor(x+0.5) or nil
  end
end

math.randomseed(os.time())