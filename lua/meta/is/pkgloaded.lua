require 'compat53'
require 'meta.gmt'
return function(x) return package.loaded[x] and true or nil end