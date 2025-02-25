require 'meta.string'
local root = require 'meta.mcache.root'
return function(x)
  if type(x)~='string' then return nil end
  if x and root[x] and root[x]~=x then
    x=x:gsub('^([^/.%s]+[/.%s])','', 1)
  end
  return x
end