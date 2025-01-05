require "meta.string"
return setmetatable({},{
__call=function(self, ...)
  local len=select('#',...)
  local __args={...}
  if len==0 or type(__args[1])=='nil' then return nil end
  return function(x)
    if type(x)~='table' then return nil end
    local args=__args
    if #args==1 and type(args[1])=='table' then args=args[1] end
    local rv={}
    if #args>0 then
      for i,k in ipairs(args) do rv[k]=x[k] end
    elseif type(next(args))~='nil' then
      for k,_ in pairs(args) do rv[k]=x[k] end
    end
    if type(next(rv))~='nil' then return rv end
  end
end,
__index=function(self, key)
  local k=key
  return function(x, b)
    if type(x)=='table' then
      if type(x[k])~='nil' then return x[k], k end
      if #x>0 then
        local rv={}
        for i,v in ipairs(x) do
          if type(v)=='table' and type(v[k])~='nil' then table.insert(rv,v[k]) end
        end
        if #rv>0 then return rv end
      elseif type(next(x))~='nil' then
        local rv={}
        for kk,v in pairs(x) do
          if type(v)=='table' and type(v[k])~='nil' then rv[kk]=v[k] end
        end
        if type(next(rv))~='nil' then return rv end
      end
      if x==k then if type(b)=='table' then return b[k], k end end
    end
  end
end,
})