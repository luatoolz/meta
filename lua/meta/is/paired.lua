local mt = require 'meta.gmt'
local ipaired = require 'meta.is.ipaired'
return function(t) return (type(t)=='table' and mt(t).__pairs and (not ipaired(t))) or nil end