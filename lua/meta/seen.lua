require "meta.table"
local iter, id =
  require "meta.iter",
  require 'meta.mt.id'
local key = {}
local ist = function(it) return type(it)=='table' end
local isf = function(it) return type(it)=='function' end
local this = {}
return setmetatable(this, {
__add		= function(self, it) if rawget(self,key) then self[it]=true; end; return self end,
__call  = function(self, it)
  if rawequal(self, this) then
    it=it or {}; return setmetatable({[key]=it}, getmetatable(self)) .. it
  else
    return (not self[it]) and it or nil
  end
end,
__concat= function(self, it)
  if type(it)=='nil' then return self end
  if rawget(self,key) then
  if ist(it) or isf(it) then
    for v in iter(it) do self[v]=true; end
  else
    if type(it)~='nil' then self[it]=true end
  end
  return self
end end,
__index = function(self, it) if rawget(self,key) then
  if it==key then return nil end
  if type(it)=='nil' then return true end
  local rv = rawget(self, id(it) or it)
  if not rv then self[it]=true end
  return rv or false
end end,
__export= function(self) return rawget(self, key) or {} end,
__iter  = function(self) if rawget(self,key) then
  return iter.ivalues(rawget(self,key))
end end,
__div   = table.div,
__mul   = table.map,
__mod		= table.filter,
__name  = 'seen',
__newindex = function(self, it, v) local data = rawget(self, key); if data then
  if type(it)=='nil' then return end; rawset(self, id(it) or it, v and true or nil)
  if v then
    table.append_unique(data, it)
  else
    local i = table.any(data, it)
    if i then table.delete(data, i) end
  end
end end,
__sub   = function(self, it) if rawget(self,key) and type(it)~='nil' then
  rawset(self, it, nil)
  self[it]=false
  return self
end end,
__tonumber = function(self) local i=0; for it,_ in pairs(self) do if it~=key then i=i+1 end end return i end,
__unm   = function(self) local me=self; return function(it) return me+it end end,
})