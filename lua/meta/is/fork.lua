local toindex, mtype, instance =
  require 'meta.is.toindex',
  require 'meta.module.type',
  require 'meta.module.instance'

return function(x) return (
  toindex(x) and
  mtype[x] and
  not instance[x]
) and true or nil end