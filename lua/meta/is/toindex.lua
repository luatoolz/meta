require 'meta.gmt'
local checker = require 'meta.checker'
return checker({['function']=true,['table']=true,['userdata']=true,['CFunction']=true}, type)