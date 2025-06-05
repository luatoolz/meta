require 'meta.gmt'
local function root(name) return type(name)=='string' and string.match(name, '^[^/.]+') end
return setmetatable({},{
set = function(self, k, v) return v and (self+k) or (self-k) end,
__add = function(self, k) k=root(k)
  if k and not self[k] then self[k]=true; table.insert(self, 1, k) end
  return self end,
__call = function(self, k) return rawget(self, root(k) or nil) end,
__index = function(self, k) return getmetatable(self)[k] or
  rawget(self, type(k)=='number' and k or (root(k) or nil)) end,
__name  = 'chain',
__pairs = ipairs,
__pow = function(self, k) _=self + k; return self end,
__sub = function(self, k)
  for i,v in ipairs(self) do if v==k then table.remove(self, i) end end
  self[k]=nil; return self; end,}) ^ 'meta'