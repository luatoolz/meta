local toskip = string.matcher('^%.*$')
return function(x) return toskip(x) and true or nil end