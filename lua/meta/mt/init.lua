require "meta.table"
--local is, pcall, checker, req, save, pkg =
local is, checker, req, pkg =
  require "meta.is",
--  require "meta.pcall",
  require "meta.checker",
  require "meta.require",
--  table.save,
  ...
local ok=checker({['table']=true,['userdata']=true,}, type)
--local pkgreq=req(pkg)
--_ = pkg
--_ = req

return setmetatable({},{
__call=function(_, self, ...)
  if not ok[self] then return nil end
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
end,
__index=req(pkg),

--__index=function(self, k)
--  if type(k)=='string' and #k>0 then
--    return assert(pkgreq(k))
--  end
--end,

--__index1=function(self, k)
--  if type(k)=='string' and #k>0 then return save(self, k, assert(pcall(require, 'meta.mt.'..k))) end
--end,
})