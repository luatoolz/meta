-- table.next.string

-- next/pairs section
-- name next*
return function(self, cur)
  local k,v = cur
  repeat k,v = next(self, k)
  until type(k)=='string' or type(k)=='nil'
  return k,v
end

--iter.next.string = iter.nexter(function(v,k) return type(k)=='string' end)
