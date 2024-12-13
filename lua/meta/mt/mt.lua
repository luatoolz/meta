require "meta.table"
local is, checker =
  require "meta.is",
  require "meta.checker"

local ok=checker({['table']=true,['userdata']=true,}, type)
return function(self, ...)
  if not ok[self] then return nil end
  local args = table {...}
  local metas = (args % is.table)
  local meta = metas[1]
  local force = (args % is.boolean)[1]
  if not meta then
    return getmetatable(self)
      or (force and getmetatable(setmetatable(self, {})) or nil)
      or (type(force) == 'nil' and {})
      or nil
  end
  local existing = getmetatable(self)
  if (not existing) or force then
    setmetatable(self, meta)
    table.remove(metas, 1)
  end
  while #metas>0 do
    meta=metas[1]
    for k,v in pairs(meta) do
      if force==false then
        if v and type(rawget(getmetatable(self), k))=='nil' then
          rawset(getmetatable(self), k, v)
        end
      else
        if rawget(getmetatable(self), k)~=v then
          rawset(getmetatable(self), k, v)
        end
      end
    end
    table.remove(metas, 1)
  end
  return self
end