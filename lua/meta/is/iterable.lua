return function(x)
	return type(x)=='table' or
		type((getmetatable(x or {}) or {}).__pairs)=='function'
end
