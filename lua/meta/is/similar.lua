local is = require "meta.is"
local ok = {
  {__call=true, __index=true, __newindex=true, __tostring=true, __eq=true,},
  {__add=true, __concat=true, __div=true, __sub=true,__le=true, __len=true, __lt=true,
  __mod=true, __mul=true,  __gc=true,__pairs=true, __pow=true, __unm=true,},}

return function(a, b)
  local rv=is.like(a, b)
  if type(rv)~='nil' then return rv end
  if not is.complex(a) then return end
  a,b = getmetatable(a), getmetatable(b)
  if not a or not b then return end
  local found=0
  for i=1,#ok do
    if found==0 then
      for k,_ in pairs(ok[i]) do
        if (a[k] or b[k]) then
          if rawequal(a[k], b[k]) then found=found+1 else return end
        end
      end
    end
  end
  return found>0 or nil
end