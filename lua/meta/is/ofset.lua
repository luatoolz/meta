local is, set = require "meta.is", require "meta.set"
return function(x) return (type(x)=='table' and is.similar(set, x)) and true or false end