local computable  = require "meta.mt.computable"
local save        = require "meta.table.save"

return function(self, k, v)
  local g = getmetatable(self) or {}
  if k~=nil and v~=nil then
    local able, uted = rawget(g, '__computable'), rawget(g, '__computed')
    if able and able[k] then
      return computable(self, able, k, v)
    end
    if uted and uted[k] then
      return save(self, k, computable(self, uted, k, v))
    end
  end
  if type(k)=='table' and #k>0 and not getmetatable(k) then
    for _,i in ipairs(k) do self[i]=v end
    return self
  end
  rawset(self, k, v)
end