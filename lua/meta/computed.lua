local mt, computed, setcomputed =
  require "meta.mt.mt",
  require "meta.mt.computed",
  require "meta.mt.setcomputed"
return function(it,...)
  local len=select('#', ...)
  if len==0 then it=it or {} end
  if type(it)=='table' then
    if len>0 then mt(it,...) end
    mt(it).__index=computed
    mt(it).__newindex = function(self, k, v)
      if mt(self).__computed[k] or mt(self).__computable[k] then
        return setcomputed(self, k, nil, v) end
      return rawset(self, k, v)
    end
    return it
  end
end