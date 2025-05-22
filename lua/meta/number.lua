require 'compat53'
local math  = require 'meta.math'

local round = math.round
local number = {}

function number:round()     return round(number(self)) end

function number:integer()   self=number(self); return (type(self)=='number' and round(self)==self) and self or nil end
function number:byte()      self=number(self); return (type(self)=='number' and round(self)==self and self>=0 and self<=255) and self or nil end
function number:natural()   self=number(self); return (type(self)=='number' and round(self)==self and self>0) and self or nil end

function number:positive()  self=number(self); return (type(self)=='number' and self>0) and self or nil end
function number:negative()  self=number(self); return (type(self)=='number' and self<0) and self or nil end

function number:zpositive() self=number(self); return (type(self)=='number' and self>=0) and self or nil end
function number:znegative() self=number(self); return (type(self)=='number' and self<=0) and self or nil end

if debug and debug.getmetatable then
  local n   = 5
  local g   = getmetatable(n) or getmetatable(setmetatable(n,{}))
  g.__index = number
end

local bases = {[2]=2, [8]=8, [10]=10, [16]=16}
return setmetatable(number, {
__call = function(_, self, base)
  if type(self)=='boolean' then return ({[true]=1,[false]=0})[self] end
  if type(self)=='number' then return self end
  if type(self)=='string' then return tonumber(self, bases[base] or 10) end
  if type(self)=='table' and (not getmetatable(self)) and #self>0 then return #self end
  if (type(self)=='table' or type(self)=='userdata') and getmetatable(self) then
    local g=getmetatable(self)
    local tn=g.__tonumber
    if type(tn)=='function' then return tn(self) end
  end
end,
__index = number,
--__index=meta.mt.pkg,
})