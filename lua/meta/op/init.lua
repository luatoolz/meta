require 'compat53'
local mt        = require 'meta.gmt'
local is        = require 'meta.is'
local selector  = require 'meta.select'
local op        = {}

op.div  = function(to)
  if type(to)=='nil' then return nil end
  if is.callable(to) then return function(...) if to(...) then return ... end end end
  local op2 = mt(to).__div
  return function(v,k) if type(v)~='nil' then
    local op1 = mt(v).__div
    if op1 then local r=op1(v,to); if r then return r,k end end
    if op2 then local r=op2(v,to); if r then return r,k else return nil end end
    if is.callable(to) then if to(v,k) then return v,k else return nil end end
    if is.string(to) or is.number(to) or is.boolean(to) then
      if is.table(v) then if v[to] then return v,k else return nil end end
      if is.func(v) then if v(to) then return v,k end end
    end
    if v==to then return v,k end
  end end
end

op.mod = function(to)
  if type(to)=='nil' then return nil end
  if is.callable(to) then return function(...) if to(...) then return ... end end end

  local sel
  if is.string(to) or is.number(to) or is.boolean(to) then sel=selector[to] end
  if is.table(to) and not getmetatable(to) then sel=selector(to) end

  local op2 = mt(to).__mod
  return function(v,k) if type(v)~='nil' then
    local op1 = mt(v).__mod
    if op1 and not mt(v).__iter then return op1(v,to) end
    if is.callable(to) then if to(v,k) then return v,k else return nil end end
    if op2 then return op2(v,to) end
    if is.string(to) or is.number(to) or is.boolean(to) then
      if is.table(v) then if v[to] then return v,k else return nil end end
    end
    if sel and sel(v,k) then return v,k end
  end end
end

op.mul = function(to)
  if type(to)=='nil' then return nil end
  if is.callable(to) then return function(...) return to(...) end end

  local sel
  if is.string(to) or is.number(to) or is.boolean(to) then sel=selector[to] end
  if is.table(to) and not getmetatable(to) then sel=selector(to) end

  local op2 = mt(to).__mul
  return function(v,k) if type(v)~='nil' then
    local op1 = mt(v).__mul
    if op1 and not mt(v).__iter then return op1(v,to) end
    if is.callable(to) then return to(v,k) end
    if op2 then return op2(v,to) end
    if is.string(to) or is.number(to) or is.boolean(to) then
      if is.func(v) then return v(to) end
    end
    if sel then return sel(v,k) end
  end end
end

return op