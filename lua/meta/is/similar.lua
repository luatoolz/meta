return function(a, b) return type(a)=='table' and type(a)==type(b) and getmetatable(a) and getmetatable(a)==getmetatable(b) or false end
