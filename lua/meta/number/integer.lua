local t = require "meta"
local to=t.to
return function(x) x=to.number(x); return x and math.round(x) or x end
