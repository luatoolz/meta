require "compat53"

local use_debug=false
local s = use_debug and ((debug or {}).setmetatable) or setmetatable

return function(t, ...) return select('#', ...) > 0 and s(t, select('1', ...)) or t end
