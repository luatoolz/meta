require "meta.string"
return setmetatable({},{
__call=function(self, ...)
  if select('#',...)==0 then return nil end
  local args={}
  for i,v in ipairs({...}) do if type(v)~='nil' then table.insert(args, v) end end
  if #args==0 then return nil end
  return function(x)
    if type(x)~='table' then return nil end
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
  return function(x)
    if type(x)=='table' then
      return x[k]
    end
  end
end,
})