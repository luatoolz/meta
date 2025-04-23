-- table.next.istrings
return function(self, cur)
  local k,v = cur
  if k==#self or type(k)=='string' then
    repeat k,v = next(self, k)
    until type(k)=='string' or type(k)=='nil'
    return k,v
  end
  k=k or 0
  if #self>0 and type(k)=='number' and k<#self then
    repeat k = k+1; v=self[k]
    until type(v)~='nil' or k>#self
    if type(k)=='number' and k>#self then return nil, nil end
  end
  return k,v
end