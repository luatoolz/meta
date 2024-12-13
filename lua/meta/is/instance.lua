local meta, is, cache, instance
return function(x)
  meta    = meta    or require "meta"
  is      = is      or meta.is
  cache   = cache   or meta.cache
  instance = instance or cache.instance
  return (is.toindex(x) and instance[x]) and true
end