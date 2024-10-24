--local t = require "meta"
--local is=t.is
require "meta.no"
local is=require "meta.is"

local function find_complex(x)
  if type(x)~='table' then return false end
  if type(x)=='table' and getmetatable(x) then return true end
  for k,v in pairs(x) do if find_complex(v) then return true end end
  return false
end

local setup={
  [true]=function(self) self.__array=true; return self end,
  [false]=function(self) self.__array=nil; return self end,
}
local complex={
  [true]=function(x) return type(x)=='table' end,
  [false]=is.complex,
}

local function exporter(x, fix, skip)
  local tofix=fix or false
  if is.virtual(x) then x=tostring(x) end
  if is.atom(x) then return x end
  local mt = getmetatable(x or {}) or {}
  local to = mt.__export
  if complex[tofix](x) then
    if type(x)=='table' and (mt.__arraytype or mt.__jsontype) then setmetatable(x, nil) end
    if is.callable(to) and not skip then x=to(x, fix)
      return ((not fix) and (skip or (not find_complex(x)))) and x or exporter(x, fix, skip)
    end
    local rv={}
    local array
    if type(x)=='table' and not getmetatable(x) then
      if x[1] or #x>0 or table.maxi(x)>0 then
        for i=1,table.maxi(x) do
          local v=x[i]
          table.insert(rv, complex[tofix](v) and exporter(v, fix) or v)
        end
        array=fix and true or false
        return setup[array](rv)
      end
      if type(next(x))~='nil' then
        for k,v in pairs(x) do
          rv[k]=exporter(v, fix)
        end
      end
      return setup[false](rv)
    end
    if mt.__pairs or mt.__iter then
      if mt.__pairs then
        for k,v in pairs(x) do
          if fix and type(k)=='number' then array=true end
          rv[k]=exporter(v, fix)
        end
      elseif mt.__iter then
        for v in table.iter(x) do
          table.insert(rv, complex[tofix](v) and exporter(v, fix) or v)
        end
        array=true
      end
      array=(fix and type(next(x))~='nil' and (array or mt.__array or mt.__arraytype)) and true or false
      return setup[array](rv)
    else
      if mt.__tostring then return tostring(x) end
    end
  end
  return x
end
return exporter