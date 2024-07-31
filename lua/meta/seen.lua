require "compat53"
require "meta.string"
require "meta.table"
return setmetatable({}, {
  __add   = function(self, x) if self.__ then x=self.__(x) end; return (not self[x]) and x or nil end,
  __call  = function(self, f) return setmetatable({__=f}, getmetatable(self)) end,
  __concat= function(self, f) return (type(f)=='function' or type(f)=='table') and table.map(f, -self) or table() end,
  __index = function(self, x) if x=='__' then return nil end; if type(x)=='nil' then return true; end; self[x]=true; return false end,
  __len   = function(self) return tonumber(self) end,
  __iter  = function(self) local k; return function() k = next(self, k); return k end end,
  __pow   = function(self, f) rawset(self, '__', f); return self end,
  __sub   = function(self, x) rawset(self, x, nil); return self end,
  __mul   = function(self, x) return self .. x end,
  __tonumber = function(self) local i=0; for k in pairs(self) do if k~='__' then i=i+1; end; end; return i end,
  __unm   = function(self) return function(x) return self + x end end,
})
