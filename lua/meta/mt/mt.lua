require "meta.table"
local is, checker =
  require "meta.is",
  require "meta.checker"

local ok=checker({['table']=true,['userdata']=true,}, type)

return function(self, ...)
  if not ok[self] then return nil end
--  if type(self)=='userdata' then return getmetatable(self) end
  local args = table {...}
  local meta = (args % is.table)[1]
  local tocreate = (args % is.boolean)[1]
  if not meta then
    return getmetatable(self)
      or (tocreate and getmetatable(setmetatable(self, {})) or nil)
      or (type(tocreate) == 'nil' and {})
      or nil
  end
  local existing = getmetatable(self)
  if not existing then
    setmetatable(self, meta)
  elseif existing ~= meta then
    for k,v in pairs(meta) do
      if rawget(existing, k)~=v then
        rawset(existing, k, v)
      end
    end
  end
  return self
end