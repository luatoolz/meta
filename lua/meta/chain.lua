require "compat53"

-- m has only static values/functions
-- chain has __ funcs

-- return meta.chain(m, ...,
--          meta.computed({fun=function(self) return "very" end}), ...
--          meta.computable({}), ...
--          meta.loader(pkgName), ...)
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
