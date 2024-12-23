local match = require "meta.mt.match"
local is, mcache, no
return function(it)
  no=no or require "meta.no"
  is=is or require "meta.is"
  mcache=mcache or require "meta.mcache"
  if type(it)=='string' then
  if not match.root(it) then return end
  if mcache.root[it] then return true end
  return mcache.pkgdir[it][1] and true
  end
  if type(it)=='table' then
    return is.loader(it) and is.root(tostring(it))
  end
end