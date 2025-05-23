require "meta.string"
local tuple = require 'meta.tuple'
local args  = tuple.args
return setmetatable({},{
__name='selector',
__call=function(self, ...)
  if select('#',...)==0 then return nil end
  local argz = args(...)
  if type(next(argz))=='nil' then return nil end
  local key = {}
  for i=1,#argz do if type(argz[i])~='nil' then key[argz[i]]=true end end
  for k,v in pairs(argz) do if type(k)~='number' then key[k]=true end end
  return function(v,k)
    if type(k)~='number' and key[k] and type(v)~='nil' and type(v)~='table' then return v,k end
    if type(v)=='table' then
      local rv={}
      for n,_ in pairs(key) do rv[n]=v[n] end
      if type(next(rv))~='nil' then return rv, (type(k)~='number' and type(k)~='nil') and k or nil end
    end
  end
end,
__index=function(self, it)
  if type(it)=='nil' then return tuple.null end
  return function(v,k)
    if type(it)~='number' and k==it and type(v)~='nil' then return v,nil end
    if type(v)=='table' and type(v[it])~='nil' then
      if type(k)=='number' or type(k)=='nil' then
        return v[it], nil
      else
        return v[it], k
      end
    end
  end
end,
})