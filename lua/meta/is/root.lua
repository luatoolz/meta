local match = require "meta.mt.match"
local is, cache, no
--local match = {
--  root = string.matcher(require "meta.matcher.root")
--}
return function(it)
  no=no or require "meta.no"
  is=is or require "meta.is"
  cache=cache or require "meta.cache"
  if type(it)=='string' then
  if not match.root(it) then return end
  if cache.root[it] then return true end
  return cache.pkgdir[it][1] and true
--  return cache.file[it] and true
  end
  if type(it)=='table' then
    return is.loader(it) and is.root(tostring(it))
  end
end