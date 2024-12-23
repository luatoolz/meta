local meta, is, mcache, instance
return function(x)
  meta    = meta    or require "meta"
  is      = is      or meta.is
  mcache   = mcache   or meta.mcache
  instance = instance or mcache.instance
  return (is.toindex(x) and instance[x]) and true
end