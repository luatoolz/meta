local meta, is, cache, factory
return function(x)
  meta    = meta    or require "meta"
  is      = is      or meta.is
  cache   = cache   or meta.cache
  factory = factory or cache.instance
  return (is.toindex(x) and factory[x]) and true
end