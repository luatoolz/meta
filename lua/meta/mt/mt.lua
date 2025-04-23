local is = require('meta.lazy').is
local search = {
__mod = function(self, to)
  local rv = {}
  for i,v in ipairs(self) do
    if to(v) then table.insert(rv, v) end
  end
  return rv
end,
}
return function(self, ...)
  if not is.complex(self) then return nil end
  local args = setmetatable({...}, search)
  local metas = (args % is.table)
  local meta = metas[1]
  local force = (args % is.boolean)[1]

  if not meta then
    return getmetatable(self)
      or (force and getmetatable(setmetatable(self, {})) or nil)
      or (type(force) == 'nil' and {})
      or nil
  end
  local start = 1
  local existing = getmetatable(self)
  if (not existing) or force then
    setmetatable(self, meta)
    start = start + 1
  end
  existing = getmetatable(self)
  for i=start,#metas do
    meta = metas[i]
    for k,v in pairs(meta) do
      if force==false then
        if v and type(rawget(existing, k))=='nil' then
          rawset(existing, k, v)
        end
      else
        if v==false then rawset(existing, k, nil) else
          if rawget(getmetatable(self), k)~=v then
            rawset(getmetatable(self), k, v)
          end end
      end
    end
  end
  return self
end