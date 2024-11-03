local is, array = require "meta.is", require "meta.array"
return function(x) return (type(x)=='table' and is.similar(array, x)) and true or false end