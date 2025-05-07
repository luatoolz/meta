local checker = require 'meta.checker'
return checker({["number"]=true,["boolean"]=true,["string"]=true,["nil"]=true,}, type)