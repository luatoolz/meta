require "meta.table"
local pcall, pkg =
  require "meta.pcall",
  ...

local function notstrings(x) return type(x)~='string' or x=='' end
local e='await prefix (strings), got: not strings or empty'

return setmetatable({},{
__call=function(self, ...)
  local prefix=self[true]
  local k=table{...}
  if #(k % notstrings)>0 then k=nil end
  k=k and table.concat(k, '.')
  if not k then return pkg:error(e) end

  if type(prefix)=='string' and #prefix>0 and type(k)=='string' and #k>0 then
    return pcall(require, prefix..'.'..k)
  end
  if type(k)~='string' or #k==0 then
    return pkg:error(e)
  end
  return setmetatable({[true]=k},getmetatable(self))
end,
__index=function(self, k)
  if type(k)=='boolean' then return rawget(self, k) end
  if type(k)=='string' and #k>0 then return self(k) end
end})