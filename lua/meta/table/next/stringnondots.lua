-- table.next.string

-- next/pairs section
-- name next*
return function(self, cur)
  local k,v = cur
  repeat k,v = next(self, k)
  until (type(k)=='string' and not k:match('^%.+$')) or type(k)=='nil'
  return k,v
end