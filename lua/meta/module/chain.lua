require 'meta.table'
local iter = require 'meta.iter'
--local append = require 'meta.table.append'
--local append = table.append
--local function ok(k) if type(k)=='string' and k~='' then return true,k end end
--local find, nextirev = table.find, require 'meta.table.next.irev'
local find = table.find
local root = string.matcher('^[^/.]+')
return setmetatable({},{
--__add = function(self, k) k=root(k); local _ = (k and (self[k] or append(self, ok(k)) and append(self, k))); return self end,
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
__iter = function(self, to) return iter.ipairs(self, to) end,
__div = iter.first,
__mul = iter.map,
__mod = iter.filter,
--__pairs = function(self) return nextirev, self end,
__pow = function(self, k) _=self + k; return self end,
__sub = function(self, k) local _ = (rawset(self, k, nil) and table.remove(self, find(self, k))); return self end,
}) ^ 'meta'