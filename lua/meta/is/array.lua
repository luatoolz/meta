local array = require 'meta.array'
return function(x) return (type(x)==type(array) and getmetatable(x)==getmetatable(array)) and true or nil end