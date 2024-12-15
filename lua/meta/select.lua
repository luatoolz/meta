require "meta.string"
return setmetatable({},{
__call=function(self, ...)
  local len=select('#',...)
  local __args={...}
  if len==0 or type(__args[1])=='nil' then return nil end
  return function(x)
    if type(x)~='table' then return x end
    local args=__args
    if #args==1 and type(args[1])=='table' then args=args[1] end
    local rv={}
    if #args>0 then
      for i,k in ipairs(args) do rv[k]=x[k] end
    elseif type(next(args))~='nil' then
      for k,_ in pairs(args) do rv[k]=x[k] end
    end
    return rv
  end
end,
__index=function(self, key)
  local kk=key
  return function(...)
    local len=select('#',...)
    if len==0 then return nil end
    local k=kk
    local a,b = ...
    if len==1 then if type(a)=='table' then return a[k] end end
    if len==2 then if b and b==k then if type(a)=='table' then return a[k] else return a end end end
    return nil
  end
end,
})