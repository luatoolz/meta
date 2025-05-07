return function(x) if type(x)~='nil' then
--  if type(x)=='string' then return x[1]=='' or x[1]=='/' or nil end
  if type(x)=='string' then return x[1]=='/' or nil end
  if type(x)=='table' then
--and #x>0 then
    if x[0]=='/' or x[0]=='' then return true end
    return type(x[1])=='string' and x[1][1]=='/' or nil
--    if type(x[1])=='string' then
--    x=x[1]
--    return (type(x)=='table' or type(x)=='string') and (x[1]=='/' or x[0]=='/' or x[0]=='') or nil
  end
end end