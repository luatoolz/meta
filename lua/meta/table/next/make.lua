require 'meta.gmt'
return function(nx, pred) if pred then
  return function(self, cur)
    local k,v = cur
    repeat k,v = nx(self, k)
    until type(k)=='nil' or pred(k)
    return k,v
  end end end