local mt = require 'meta.gmt'
return function(x) return type(x)=='table' and mt(x).__preserve and mt(x).__iter and (mt(x).__mul or mt(x).__mod or mt(x).__div) end