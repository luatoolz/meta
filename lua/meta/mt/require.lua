require "meta.table"
local join, call, pkg =
  string.dot:joiner(),
  require "meta.call",
  ...

local function notstrings(x) return type(x)~='string' or x=='' end

return setmetatable({},{
__call=function(self, ...)
  local prefix=self[true]
  local k=table{...}
  if #(k % notstrings)>0 then k=nil end
  k=k and join(k)
  if not k then return pkg:error('await prefix (string), got %s' ^ type(k)) end

  if type(prefix)=='string' and #prefix>0 and type(k)=='string' and #k>0 then
    local path=join(prefix, k)
    local rv=package.loaded[path]
    if type(rv)~='nil' then return rv end
    return call(require, path)
  end
  if type(k)~='string' or #k==0 then
    return pkg:error('await prefix (string), got: %s' ^ type(k))
  end
  return setmetatable({[true]=k},getmetatable(self))
end,
__index=function(self, k)
  if type(k)=='boolean' then return rawget(self, k) end
  if type(k)=='string' and #k>0 then return self(k) end
end})