require 'meta.table'
local find = table.find
local root = string.matcher('^[^/.]+')
return setmetatable({},{
__add = function(self, k)
  k=root(k)
  if not self[k] then
    self[k]=true
    table.insert(self, 1, k)
  end
  return self
end,
__call = function(self, k) return rawget(self, root(k) or nil) end,
__index = function(self, k) return rawget(self, type(k)=='number' and k or (root(k) or nil)) end,
__div = table.div,
__mul = table.map,
__mod = table.filter,
__name  = 'chain',
__pairs = ipairs,
__pow = function(self, k) _=self + k; return self end,
__sub = function(self, k) return self, (rawset(self, k, nil) and table.remove(self, find(self, k))) end,
}) ^ 'meta'