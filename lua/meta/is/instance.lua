local toindex, instance =
  require 'meta.is.toindex',
  require 'meta.module.instance'

return function(x)
  if toindex(x) then
    return instance[x] and true or nil
end end