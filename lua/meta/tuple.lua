require 'compat53'
require 'meta.gmt'

local tuple = {}

function tuple.n(...)       local rv = select('#', ...); return rv>0 and rv or nil end
function tuple.args(...)    local n,rv = select('#', ...),{...}; return (n==1 and type(rv[1])=='table') and rv[1] or rv end
function tuple.good(x, ...) if type(x)~='nil' then return tuple(x, ...) end return nil end

function tuple.null(x)      return nil    end
function tuple.noop(...)    return ...    end
function tuple.swap(a,b)    return b,a    end
function tuple.k(_,k)       return k,nil  end
function tuple.kk(_,k)      return k,k    end
function tuple.v(v)         return v,nil  end
function tuple.vv(v)        return v,v    end

return setmetatable(tuple, {
--[[
__add=function(self, a)
  local n=(self.n or #self)+1
  self[n]=a
  self.n=n
  return self
end,
--]]
__call=function(self, ...)
  if rawequal(self, tuple) then return setmetatable(table.pack(...),getmetatable(self)) end
  if not rawequal(self, tuple) then return table.unpack(self) end
end,
--[[
__concat=function(self, it)
print(' __concat', (getmetatable(self) or {}).__name or type(self), (getmetatable(it) or {}).__name or type(it))

  if rawequal(getmetatable(tuple),getmetatable(self)) then
--  local rv = tuple(self())
  local rv = tuple()
  if not rawequal(tuple, self) then
    for _,v in ipairs(self) do _=rv+v end
  end

  if type(it)=='function' then
    for v in it do _=rv+v end
  end
  if type(it)=='table' and ((not getmetatable(it)) or getmetatable(it).__name=='tuple') then
    for _,v in ipairs(it) do _=rv+v end
  else
    if it~=nil then _=rv+it end
  end
  return rv
else
  print(' FAIL tuple')
end end,
--]]
__index=function(self, k) return rawget(self, k) or rawget(tuple, k) or nil end,
__pairs=ipairs,
__name='tuple',
})