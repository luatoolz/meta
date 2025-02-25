require 'meta.no'
local is, mcache, instance
return function(x)
  is       = is       or require 'meta.is'
  mcache   = mcache   or require 'meta.mcache'
  instance = instance or mcache.instance
  return (is.toindex(x) and instance[x]) and true
end