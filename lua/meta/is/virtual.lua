local checker = require 'meta.checker'
return checker({["function"]=true,["thread"]=true,["CFunction"]=true,}, type)