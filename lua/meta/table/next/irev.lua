-- table.next.irev (reversed)
return function(a, i)
  i = i and i - 1 or #a
  local v = a[i]
  if v then
    return i, v
  end
end