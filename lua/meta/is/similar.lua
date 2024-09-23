local ok = {
__call=true, __index=true, __newindex=true, __tostring=true, __eq=true,
__add=true, __concat=true, __div=true, __sub=true,
}
local ok2 = {
__le=true, __len=true, __lt=true, __mod=true, __mul=true,  __gc=true,
__pairs=true, __pow=true, __unm=true,
}

return function(a, b)
  if type(a)~=type(b) or type(a)~='table' then return false end
  local ma,mb = getmetatable(a), getmetatable(b)
  if type(ma)=='nil' and type(mb)=='nil' then return true end
  ma=ma or {}
  mb=mb or {}

  local found=0
  for k,_ in pairs(ok) do
    if (ma[k] or mb[k]) then
      if rawequal(ma[k], mb[k]) then found=found+1 else return false end
    end
  end
  if found==0 then
    for k,_ in pairs(ok2) do
      if (ma[k] or mb[k]) then
        if rawequal(ma[k], mb[k]) then found=found+1 else return false end
      end
    end
  end
  return found>0
end
