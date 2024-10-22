local pkg = ...
return function(d)
  if type(d)=='nil' then return end
  if type(d)~='string' then return nil, '%s: wrong type: %s' % {pkg, type(d)} end
  d=d=='' and '.' or d
  local rv = io.open(d, "r")
  if rv==nil then return nil end
  local pos = rv:read("*n")
  local it = rv:read(1)
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return (pos==nil and it==nil and en~=0 and cl) and true or nil
  end