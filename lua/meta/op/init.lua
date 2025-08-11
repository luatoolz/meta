require 'compat53'
local mt        = require 'meta.gmt'
local is        = require 'meta.is'
local selector  = require 'meta.selector'
local tuple     = require 'meta.tuple'
local op        = {}

op.div  = function(to)
  if type(to)=='nil' then return nil end
  if is.callable(to) then return function(...)
    local t=tuple(to(...))
    local a=t and t[1]
    if a and a~=true then return t() end
    if a and a==true then return ... end
    return nil end end

  return function(v,k) if type(v)~='nil' then
    if is.string(to) or is.number(to) or is.boolean(to) then
      if is.table(v) then

--[[
        local g = getmetatable(v)
        if type(g)=='table' then
          if g.__div then
            local rv = g.__div(v,to)
            if type(rv)~='nil' then return rv,k end
          end
--]]
--[[
          else
          if g.__mul then
            local rv = g.__mul(v,to)
            if type(rv)~='nil' then return rv,k end
          elseif g.__mod then
            local rv = g.__mod(v,to)
            if rv then return v,k end
          end
          return nil
--]]
--        end

        local w=v[to];
        if w and w~=true then return w,k end
        if w and w==true then return v,k end
        if k==to then return v,k else return nil end
      end
      if is.func(v) then
        local t=tuple(v(to))
        if t and t[1] and t[1]~=true then return t() end
        if t and t[1] and t[1]==true then return v,k end
      end
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

  return function(v,k) if type(v)~='nil' then
    local op1 = mt(v).__mod
    if op1 and not mt(v).__iter then return op1(v,to) end
    if is.string(to) or is.number(to) or is.boolean(to) then
      if is.table(v) then if v[to] or k==to then return v,k else return nil end end
    end
    if sel and sel(v,k) then return v,k end
  end end
end

op.mul = function(to)
  if type(to)=='nil' then return nil end
  if is.callable(to) then return to end

  local sel
  if is.string(to) or is.number(to) or is.boolean(to) then sel=selector[to] end
  if is.table(to) and not getmetatable(to) then sel=selector(to) end

  return function(v,k) if type(v)~='nil' then
    local op1 = mt(v).__mul
    if op1 and not mt(v).__iter then return op1(v,to) end
    if is.string(to) or is.number(to) or is.boolean(to) then
      if is.func(v) then return v(to) end
    end
    if sel then return sel(v,k) end
  end end
end

return op