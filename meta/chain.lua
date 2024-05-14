require "compat53"
-- return meta.chain({static_field="value"}, meta.computed({ fun=function(self) return "very" end}), meta.loader(pkgName))
return function(...)
  local mt = {...}
  local t = {}
  return setmetatable(t, { __index = function(self, key)
    for i,it in pairs(mt) do
      local it_mt = getmetatable(it)
      if type(it_mt)=='table' then
        local rv
        local mmethod = it_mt.__index
        if(type(mmethod) == "function") then
          rv = mmethod(self, key)
          if rv~=nil then
            return rv
          else
          end
        else
          rv = mmethod[key]
          if rv~=nil then
            return rv
          end
        end
      else
        rv = it[key]
        if rv~=nil then
          return rv
        end
      end
    end
    return nil
  end})
end
