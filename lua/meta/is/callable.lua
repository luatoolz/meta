return function(x) return (type(x)=='function' or (type(x)=='table' and type((getmetatable(x or {}) or {}).__call)=='function')) and true or false end
