require 'meta.gmt'
-- clone table with mt by default
-- nogmt=true to drop mt
local function clone(self, o, nogmt)
  if type(self)~='table' then return self end
  local rv = (type(o)~='nil' and nogmt) and clone(o, nil, nogmt) or {}
  for k, v in pairs(self) do
    if k~=nil and v~=nil and (k~='__index' or nogmt) then
      if not rawget(rv, k) then
        v = clone(v)
        rawset(rv, k, v)
      end
    end
  end
  if not nogmt then
    local gmt = getmetatable(self)
    if gmt or o then
      setmetatable(rv, clone(gmt, o, true))
    else
      local k = '__index'
      local v = rawget(self, k)
      if v and not rawget(rv, k) then
        rv.__index=clone(v)
        setmetatable(rv, rv)
      end
    end
  end
  return rv
end
return clone