local meta, is, cache, typed
return function(t, x)
  meta    = meta    or require "meta"
  is      = is      or meta.is
  cache   = cache   or meta.cache
  typed   = typed   or cache.type
  return (is.toindex(x) and t==typed[x]) or t==nil or nil
end