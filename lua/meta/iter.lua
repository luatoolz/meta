require 'compat53'
require 'meta.gmt'
require 'meta.math'

local iter = {}

local checker = require 'meta.checker'
local selector = require 'meta.select'
local co = require 'meta.call'
local pairs, ipairs, select = pairs, ipairs, select

local fn = {
  noop = require 'meta.fn.noop',
  null = function() end,
  swap = function(a,b) return b,a end,
  ok    = function() return true end,
  tuple = function(...) return ... end,
}
local mt = function(x) return x and getmetatable(x) or {} end

local maxi     = require 'meta.table.maxi'
local preserve = require 'meta.table.preserve'
local append   = require 'meta.table.append'
local _ = selector

local is = {
  func = function(x) return type(x)=='function' end,
  callable = require 'meta.is.callable',
  mappable = checker({
    ['function'] = true,
    table = true,
    userdata = function(x) local gmt=mt(x); return (gmt.__pairs or gmt.__iter) and true or nil end,
  }, type),
  iterable = function(x) return mt(x).__iter and true or nil end,
  ipairable = function(x)
    local gmt = x and getmetatable(x) or {}
    return gmt.__pairs==ipairs or mt(x).__ipairs or ((not gmt.__pairs) and (type(x)=='table' and #x>0))
  end,
  pairable = function(x)
    return mt(x).__pairs or type(x)=='table'
  end,
  iter = function(x)
    return x and rawequal(getmetatable(iter),getmetatable(x)) or nil
  end,
}

local function addindex(i, x, ...)
  if type(x)~='nil' then
    if select('#', ...)>0 then
      return x, ...
    else
      if type(i)~='nil' and type(i)~='number' then
        return x, i
      else
        return x
      end
    end
  end
end

function make_filter(fl)
  if not is.callable(fl) then return function(x, ...) if type(x)~='nil' then return x, ... end end end
  return function(v, k) if fl(v, k) then return v, type(k)~='number' and k or nil end end
end
local _ = make_filter
---------------------------------------------------------------------------------------------

function iter.range(...)
  local n = select("#", ...)
  local from, to, increment = 1, nil, 1
  if n == 1 then      to = ...
  elseif n == 2 then  from, to = ...
  elseif n == 3 then  from, to, increment = ...
  elseif n~=0 then error"range requires 1-3 arguments" end
  if increment==0 then error"wrong increment (0)" end

  local i = from-increment
  if not to then return function()
    i = i + increment
    return i
  end end
  if increment>0 then return function()
    if i>=to then return end
    i = i + increment
    return i
  end else return function()
    if i<=to then return end
    i = i + increment
    return i
  end end
end

function iter.mul(self, f)
  f=f and co.pcaller(f)
  return f and co.wrap(function ()
    for v,k in iter.iter(self) do co.yieldok(addindex(k, f(v,k))) end
  end) or self
end

function iter.mod(self, f)
  f=f and co.pcaller(f)
  return f and co.wrap(function ()
    for v,k in iter.iter(self) do
      local r = f(v,k)
      if type(r)=='function' then
        while co.alive(r) do co.yieldok(r()) end
      elseif r then co.yieldok(v, k) end
    end
  end) or self
end

function iter.ipairs(self, use_mt) if type(self)=='table' then
  local gmt = getmetatable(self) or {}
  local ipairz = gmt.__ipairs
  local max = maxi(self)
  if max and max>0 and (type(ipairz)=='nil' or use_mt==false) then
    return co.wrap(function() for i=1,maxi(self) do co.yieldok(self[i], i) end end)
  end
  ipairz=ipairz or ipairs
  return co.wrap(function() for i,v in ipairz(self) do co.yieldok(v, i) end end)
else return fn.null end end

function iter.pairs(self, use_mt) if type(self)=='table' then
  return use_mt==false and co.wrap(function() for k,v in next,self   do co.yieldok(v, k) end end)
                        or co.wrap(function() for k,v in pairs(self) do co.yieldok(v, k) end end)
else return fn.null end end

local function keys(v,k) return k,nil end
local function key_not_number(v,k) return type(k)~='number' end
local function key_string(v,k) return type(k)=='string' end

function iter.ivalues(self) return iter.ipairs(self, false) end
function iter.svalues(self) return iter.mod(iter.pairs(self, false), key_string) end
function iter.values(self)  return iter.mod(iter.pairs(self, false), key_not_number) end

function iter.ikeys(self)   return iter.mul(iter.ipairs(self, false), function(v,i) return i end) end
function iter.keys(self)    return iter.mul(iter.mod(iter.pairs(self, false), key_not_number), keys) end
function iter.skeys(self)   return iter.mul(iter.mod(iter.pairs(self, false), key_string), keys) end

function iter.items(self)
  if type(self)=='nil' then return fn.null end
  local pairz = mt(self).__pairs
  if pairz then return iter.pairs(self) end
  return co.wrap(function()
    for v,i in iter.ivalues(self) do co.yieldok(v,i) end
    for v,k in iter.values(self) do co.yieldok(v,k) end
  end)
end

function iter.tuple(...) return iter.ivalues({...}) end
function iter.args(...) local n,rv = select('#', ...),{...}; return (n==1 and type(rv[1])=='table') and rv[1] or rv end

function iter.collect(it, rv, recursive)
  is.bulk = is.bulk or require 'meta.is.bulk'
  rv=rv or {}
  for v,k in it do
    if (is.iter(v) or is.func(v)) and recursive then iter.collect(v, rv, recursive)
    else
      append(rv, v, type(k)~='number' and k or nil)
    end
  end
  return rv
end

function iter.it(self)
  if type(self)=='nil' then return nil end
  if is.iter(self) then return self.it end
  if type(self)=='function' then return self end
  local gmt = getmetatable(self)
  if (type(self)=='table' or type(self)=='userdata') and gmt then
    local iterf, pairz, ipairz = gmt.__iter, gmt.__pairs, gmt.__ipairs
    if iterf then return iter.iter(iterf(self)) end
    if pairz then return iter.iter(iter.pairs(self)) end
    if ipairz then return iter.iter(iter.ipairs(self)) end
  end
  if type(self)=='table' then return iter.items(self) end
end

function iter.iter(self, v)
  local it = iter.it(self)
  return (it and is.callable(v)) and iter.mul(it, v) or it
end

function iter.map(self, f)
  if not is.mappable(self) then return nil end
  local rv = preserve(self)
  return iter.collect(iter(self)*f, rv, true)
end

function iter.filter(self, f)
  if not is.mappable(self) then return nil end
  local rv = preserve(self)
  return iter.collect(iter(self)%f, rv, true)
end

function iter.first(self, f)
  if not is.mappable(self) then return nil end
  return iter(self)/f
end

function iter.each(self, f) if is.callable(f) then
  for v,k in iter(self) do f(v,k) end
end end

function iter.reduce(self, f, acc)
  assert(is.callable(f), 'invalid caller')
  local it = iter(self)
  acc=acc or it()
  for v in it do acc = f(acc, v) end
  return acc
end

function iter.find(self, f)
  assert(type(f)~='nil', 'invalid predicate')
  local ok=f
  if not is.callable(ok) and type(ok)~='nil' then
    ok = function(v,k) if f==v then return v,k end end
  end
  for v,k in iter(self) do if ok(v, k) then return v,k end end
end

--[[
iter.next = setmetatable({},{
__call = function(_, ...)
  return next(...)
end,
})
function iter.nexter(pred, __next)
  assert(is.callable(pred), 'predicate not callable')
  local tonext = __next or next
  return function(self, cur)
    local k,v = cur
    repeat k,v = tonext(self, k)
    until type(k)=='nil' or pred(k)
    return k,v
  end
end
function iter.next.i(self, cur)
  local max = maxi(self)
  local i,v = cur
  repeat i = (i or 0)+1; v=self[i]
  until type(v)~='nil' or (max and i>max)
  if type(i)=='number' and max and i>max then return nil, nil end
  return i,v
end
iter.next.string = iter.nexter(function(v,k) return type(k)=='string' end)
--]]

function iter.sum(self) return iter.reduce(self, function(a,b) return a+b end, 0) end
function iter.count(self) return iter.reduce(self, function(a,b) return a+1 end, 0) end

--[[
--  __mod = function(self, to) return end,
--    __mod                     -- pass to iter
--    callable                  -- pass pred to iter
--    boolean                   -- ??
--    string                    -- pat/rex
--  return iterator
  __mul = function(self, to)
--    __mul                     -- pass to iter
--    callable                  -- handler
--    boolean                   -- preload
--    string/number/plain table -- selector (to __index?)
--  return iterator

--  pass __mul / return iter
    if is.callable(to) then return iter.map(self)*to end
    if type(to)=='boolean' then if to then return self.load else return self.loader end end
    if type(to)=='string' or type(to)=='number' or (type(to)=='table' and not getmetatable(to)) then
      return iter(self, function(v,k) return v[to],k end)
    end
--  -1, -5, 2, 5                  -- negative indexes
--  {1}, {2,5}                    -- interval
--  {x,y,z, aaa, bbb, ccc}        -- list of item names
--  {true,false,str const,true}   -- tuple reformat
  end,
--]]

return setmetatable(iter,{
__concat = function(r, it)
  if type(r)=='table' then
    return iter.collect(it, r, true)
  end
end,
__call = function(self, ...)
  local len = select('#', ...)
  local it, to = ...
  if len==0 or type(it)=='nil' then
    it = self.it
    if not it then return nil, nil end
    return it()
  end
  if is.iter(it) and not to then return it end
  return setmetatable({it=iter.it(it)}, getmetatable(iter))*to
end,
__iter = function(self, to) return iter.iter(self, to) end,
__div = function(self, to)
  if type(to)=='nil' then return nil end

--[[
  if mt(to).__div then
    to=function(v,k) if type(v)~='nil' then
      return v/to
    end end
    return iter.find(iter(self), to)
  end
--]]

  local sel
--  if type(to)=='string' or type(to)=='number' then sel=selector[to] end
  if type(to)=='table' and not getmetatable(to) then sel=selector(to) end

  local cc=to
  if not is.callable(to) then
    cc=function(v,k) if type(v)~='nil' then
--print(' __cc', v, k, to, v[to])
--[[
    local m1, m2 = mt(v).__div, mt(to).__div
--    if m1 then return m1(v,to) end
    if m1 or m2 then return m1(v,to) end
    if sel then return sel(v,k) end
    if is.callable(to) then return to(v,k) end
    return nil
--]]
    local m1, m2 = mt(v).__div, mt(to).__div
--    m1 = (m1 and m1~=iter.first) and m1 or nil
--    m2 = (m2 and m2~=iter.first) and m2 or nil
    return (m1 and m1(v,to)) or (m2 and m2(v,to)) or (sel and sel(v,to))
  end end
end

  return iter.find(iter(self, cc), fn.noop)
end,
__mul = function(self, to)
  if type(to)=='nil' then return self end

--[[
  local mul = mt(to).__mul
  if mul then
    to=function(v,k) if type(v)~='nil' then
      return mul(v,to)
    end end
  end
--]]

--  local sel
--  if type(to)=='string' or type(to)=='number' then sel=selector[to] end
  if type(to)=='table' and not getmetatable(to) then to=selector(to) end

  local cc=to
  if not is.callable(to) then
    cc = function(v,k) if type(v)~='nil' then
    if type(to)=='string' and type(v)=='table' and not mt(v).__mul then return v[to],k end
--    local m1 = mt(v).__mul
----    local m1, m2 = mt(v).__mul, mt(to).__mul
--    if m1 then return m1(v,to) end
    local m1, m2 = mt(v).__mul, mt(to).__mul
--    m1 = (m1 and m1~=iter.map) and m1 or nil
--    m2 = (m2 and m2~=iter.map) and m2 or nil

    if (m1 or m2) then return v*to end
--    if sel then return sel(v,k) end
    if is.callable(to) then return to(v,k) end
    return nil
--    return (m1 or m2) and v*to or (sel and sel(v,k)) or (is.callable(to) and to(v,k)) or nil
--    if m1 or m2 then return v*to end
--    return sel and sel(v,to)
--[[
    local rv
    if m2 then rv=rv or m2(v,to) end
    if m1 then rv=rv or m1(v,to) end
    if sel then rv=rv or sel(v,k) end
    return rv
--]]
--    return (m1 and m1(v,to)) or (m2 and m2(v,to)) or (sel and sel(v,to))
  end end end

  return iter(iter.mul(self, cc))
end,
__mod = function(self, to)
  if type(to)=='nil' then return self end
--  if type(to)=='string' or type(to)=='number' then to=selector[to] end
  if type(to)=='table' and not getmetatable(to) then to=selector(to) end

  local cc=to
  if not is.func(to) then
    cc = function(v,k)
      if type(v)~='nil' then
        local m1, m2 = mt(v).__mod, mt(to).__mod
--[[
--    m1 = (m1 and m1~=iter.filter) and m1 or nil
--    m2 = (m2 and m2~=iter.filter) and m2 or nil
    if (m1 or m2) then return v%to and true or nil end
    if is.callable(to) then return to(v,k) and true or nil end
--    return (m1 and m1(v,to)) or (m2 and m2(v,to))
--]]
        return ((m1 or m2) and v%to or (is.callable(to) and to(v,k)))
      end end end
  return iter(iter.mod(self, cc))
end,
__name = 'iter',
})