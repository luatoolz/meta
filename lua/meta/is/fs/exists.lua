local fs=require('meta.fs')
return function(x) return fs.exists(x) end