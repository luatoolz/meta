local t = require "meta"
local to, date = t.to, t.date
return function(x) return to.number(date(x)) end