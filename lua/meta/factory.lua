local mt, factory =
  require "meta.mt.mt",
  require "meta.mt.factory"
return function(it,...)
  local len=select('#', ...)
  if len==0 then it=it or {} end
  if type(it)=='table' then
    if len>0 then mt(it,...) end
    return mt(it,{__index=factory})
  end
end