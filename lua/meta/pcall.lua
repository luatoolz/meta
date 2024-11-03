local xpcall = require "meta.xpcall"
return function(f, ...) return xpcall(f, nil, ...) end