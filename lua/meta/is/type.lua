local meta, is, mcache, typed
return function(name, x)
  meta    = meta    or require "meta"
  is      = is      or meta.is
  mcache  = mcache  or meta.mcache
  typed   = typed   or require "meta.type"
  return (is.toindex(x) and name==typed(x)) or name==nil or nil
end