local math  = require 'meta.math'
local round = math.round
return function(self) return (type(self)=='number' and round(self)==self and self>0) and true or nil end