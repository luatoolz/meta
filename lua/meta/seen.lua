require "compat53"
require "meta.string"
require "meta.table"
local ist = function(it) return type(it)=='table' end
local isf = function(it) return type(it)=='function' end
return setmetatable({}, {
  __add		= function(self, it) self[it]=true; return self end,
  __call  = function(self, it) return setmetatable({__=it}, getmetatable(self)) .. it end,
  __concat= function(self, it) if ist(it) or isf(it) then table.map(it, -self) else if type(it)~='nil' then self[it]=true end; end; return self end,
  __index = function(self, it) if it=='__' then return nil end;if type(it)=='nil' then return true end;self[it]=true;return false;end,
  __len   = function(self) return tonumber(self) end,
  __iter  = function(self) return ist(self.__) and table.ivalues(self.__) or table.keys(self) end,
	__mod		= table.filter,
  __mul   = table.map,
	__newindex = function(self, it, v) if type(it)=='nil' then return end; rawset(self, it, v and true or nil)
		if v then table.append_unique(self.__, it) else table.delete(self.__, table.findvalue(self.__, it)) end end,
  __pow   = function(self, it) return (ist(it) and not rawget(self, '__')) and (rawset(self, '__', it) .. it) or self end,
  __sub   = function(self, it) rawset(self, it, nil); self[it]=nil; return self end,
  __tonumber = function(self) local i=0; for it,_ in pairs(self) do if it~='__' then i=i+1 end end return i end,
  __unm   = function(self) return function(it) self[it]=true end end,
})
