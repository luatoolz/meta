--require 'meta.no'
local toindex, instance, cacher =
  require 'meta.is.toindex',
  require 'meta.module.instance',
  require 'meta.module.cacher'

return function(x)
--  is       = is       or require 'meta.is'
--  mcache   = mcache   or require 'meta.mcache'
--  instance = instance or require 'meta.module.instance'
  if toindex(x) then
    cacher()
    return instance[x] and true or nil
end end