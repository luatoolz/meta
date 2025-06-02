local null = require 'meta.null'
return function(o) return (type(o)=='nil' or rawequal(null,o)) and true or nil end