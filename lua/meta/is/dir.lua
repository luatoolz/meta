require 'meta.gmt'
local call = require 'meta.call'
local pkg = ...
local dir, path
return function(d)
  path=path or call(require,'meta/path')
  dir=dir   or call(require,'meta/dir')
  if type(d)=='nil' then return pkg:error('is.dir is nil') end
  if (type(d)=='table' or type(d)=='userdata') and getmetatable(d) then
    return (type(dir)=='table' and rawequal(getmetatable(dir),getmetatable(d))) or
           (type(path)=='table' and rawequal(getmetatable(path),getmetatable(d)) and d.isdir)
           or nil
  end
  if type(d)=='string' then return (d=='' or d=='.' or d=='..') and true or path(d).isdir end
  if type(d)~='string' then return pkg:error('wrong type: %s' ^ type(d), d) end
  d=d=='' and '.' or d
  local rv = io.open(d, "r")
  if rv==nil then return nil end
  local pos = rv:read("*n")
  local it = rv:read(1)
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return (pos==nil and it==nil and en~=0 and cl) and true or nil
  end