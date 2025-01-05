local mt, computed =
  require "meta.mt.mt",
  require "meta.mt.computed"
return function(it,...)
  local len=select('#', ...)
  if len==0 then it=it or {} end
  if type(it)=='table' then
    if len>0 then mt(it,...) end
    mt(it).__index=computed
    return it
  end
end