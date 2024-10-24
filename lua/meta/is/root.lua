local is, cache, no
return function(it)
  no=no or require "meta.no"
  is=is or require "meta.is"
  cache=cache or require "meta.cache"
  if not is.match.root(it) then return end
  if cache.root[it] then return true end
--  return cache.pkgdir[it][1] and true
  return cache.file[it] and true
end