local meta, is, mcache, typed
return function(t, x)
  meta    = meta    or require "meta"
  is      = is      or meta.is
  mcache  = mcache  or meta.mcache
  typed   = typed   or mcache.type
  return (is.toindex(x) and t==typed[x]) or t==nil or nil
end