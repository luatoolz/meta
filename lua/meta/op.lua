local _ = require 'meta.call'
local selector = require 'meta.select'
local meta = require 'meta.lazy'
local is, fn = meta({'is', 'fn'})
local mt = fn.mt
local op = {}

op.div  = function(to)
  if type(to)=='nil' then return nil end
  if type(to)=='function' or is.callable(to) then return function(...) if to(...) then return ... end end end
  local sel
  if type(to)=='string' and to~='' then sel=selector[to] end

  local op2 = mt(to).__div
  return function(v,k) if type(v)~='nil' then
    local op1 = mt(v).__div
    if (op2) then return op2(v,to),k end
    if op1 and type(to)=='string' then return op1(v,to),k end
    if sel and sel(v,k) then return v,k end
    if (op1 or op2) then return v/to,k end
    if v==to or k==to then return v,k end
  end end
end

op.mod = function(to)
  if type(to)=='nil' then return nil end
  if type(to)=='function' or is.callable(to) then return function(...) if to(...) then return ... end end end

  local sel
  if type(to)=='string' then sel=selector[to] end
--  if type(to)=='table' and not getmetatable(to) then sel=selector(to) end

  local op2 = mt(to).__mod
  return function(v,k) if type(v)~='nil' then
    local op1 = mt(v).__mod
    if (op1 or op2) then return op1(v,to) end
    if sel and sel(v,k) then return v,k end
  end end
end

op.mul = function(to)
  if type(to)=='nil' then return nil end
  if type(to)=='function' or is.callable(to) then return function(...) return to(...) end end

  local sel
  if type(to)=='string' or type(to)=='number' then sel=selector[to] end
  if type(to)=='table' and not getmetatable(to) then sel=selector(to) end

  local op2 = mt(to).__mul
  return function(v,k) if type(v)~='nil' then
    local op1 = mt(v).__mul
    if (op1 or op2) then return v*to end
    if sel then return sel(v,k) end
  end end
end

return op