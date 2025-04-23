return function(a, b)
  if type(a)=='nil' or type(b)~='table' then return nil end
  return type(b[a])~='nil'
end