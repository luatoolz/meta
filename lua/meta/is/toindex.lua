require 'meta.gmt'
local checker = require 'meta.checker'
return checker({['function']=true,['table']=true,['userdata']=getmetatable,['CFunction']=true}, type)