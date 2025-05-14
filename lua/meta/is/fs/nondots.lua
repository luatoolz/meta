local dots = string.matcher('^%.*$')
return function(x) return (not dots(x)) or nil end