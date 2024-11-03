require "meta.table"

return function(self, x, e, ...)
  if e and not x then return nil, '%s: %s' % {self, e} end
  return x, e, ...
end