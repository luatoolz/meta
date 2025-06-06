require 'compat53'
if debug then
  if getmetatable~=debug.getmetatable then getmetatable=debug.getmetatable end
  if setmetatable~=debug.setmetatable then setmetatable=debug.setmetatable end
end

local is = {
  null    = function(x) return type(x)=='nil' or nil end,
  table   = function(x) return type(x)=='table' or nil end,
  string  = function(x) return type(x)=='string' or nil end,
  boolean = require 'meta.is.boolean',
}

local search = {
__mod = function(self, to)
  local rv = {}
  for i=1,self.n do
    local v=self[i]
    if type(v)~='nil' then
      if to(v) then table.insert(rv, v) end
    end
  end
  return rv
end,
}
return function(self, ...)
  if is.null(self) then return nil end
  local args = setmetatable(table.pack(...), search)
  if #args>0 and is.string(args[1]) then return (getmetatable(self) or {})[args[1]] end
  assert(type(args)=='table', 'args is not table')
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