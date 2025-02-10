require 'compat53'
require 'meta.gmt'
require 'meta.math'

local iter = {}

if (not package.loaded['meta.table']) and (not table.iter) and not table.maxi then
  assert(require 'meta.table')
end
table.iter = iter

local checker = require 'meta.checker'
local co = require 'meta.call'
local pairs, ipairs, select = pairs, ipairs, select

local fn = {
  noop = require 'meta.fn.noop',
  null = function() end,
}
local mt = function(x) return x and getmetatable(x) or {} end

local maxi     = table.maxi
local preserve = table.preserve

local is = {
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
  f=(f and is.callable(f)) and make_filter(f) or nil
  return f and iter.mul(self, f) or self
end

function iter.ipairs(self, use_mt) if type(self)=='table' then
  local gmt = getmetatable(self) or {}
  local ipairz = gmt.__ipairs
  local max = maxi(self)

  if max and max>0 and (type(ipairz)=='nil' or use_mt==false) then
    return co.wrap(function()
      for i=1,maxi(self) do co.yieldok(self[i], i) end
    end)
  end
  ipairz=ipairz or ipairs
  return co.wrap(function()
    for i,v in ipairz(self) do co.yieldok(v, i) end
  end)
else return fn.null end end

function iter.pairs(self, use_mt) if type(self)=='table' then
  return use_mt==false and co.wrap(function()
    for k,v in next,self do co.yieldok(v, k) end
  end) or co.wrap(function()
    for k,v in pairs(self) do co.yieldok(v, k) end
  end)
else return fn.null end end

function iter.ivalues(self) return iter.ipairs(self, false) end
function iter.ikeys(self)   return iter.mul(iter.ipairs(self, false), function(v,i) return i end) end
function iter.keys(self)    return iter.mul(iter.pairs(self, false),  function(v,k) if type(k)~='number' then return k,nil end end) end
function iter.values(self)  return iter.mul(iter.pairs(self, false),  function(v,k) if type(k)~='number' then return v,k end end) end
function iter.skeys(self)   return iter.mul(iter.pairs(self, false), function(v,k) if type(k)=='string' then return k,nil end end) end
function iter.svalues(self) return iter.mul(iter.pairs(self, false), function(v,k) if type(k)=='string' then return v,k end end) end

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

function iter.collect(self, rv)
  rv=rv or preserve(self)
  for v,k in iter(self) do
    table.append(rv, v, type(k)~='number' and k or nil) end
  return rv
end

function iter.iter(self, values)
  if is.iter(self) then
    if is.callable(values) then
      return iter.mul(self.it, values)
    else
      return self.it
    end
  end
  if type(self)=='function' then
    if is.callable(values) then
      return iter.mul(self, values)
    else
      return self
    end
  end
  if type(self)~='table' and type(self)~='userdata' then return fn.null end
  if is.iterable(self) then
    local iterf = mt(self).__iter
    if is.callable(iterf) then
      local rv=iterf(self)
      if is.callable(values) then
        return iter.iter(rv, values)
      else
        return is.iter(rv) and iter.iter(rv) or rv
      end
    end
  end
  return iter.mul(iter.items(self), values)
end

function iter.map(self, f)
  local rv = preserve(self)
  assert(getmetatable(rv) == getmetatable(table()))
  if not is.mappable(self) then return rv end
  return iter.collect(iter(self, f), rv)
end

function iter.filter(self, f)
  if type(self)~='table' and type(self)~='function' then return end
  if type(f)=='number' then return end
  if type(f)=='string' and #f==0 then return end
  if type(f)=='string' and #f>0 then f={f} end
  if type(f)=='table' and not getmetatable(f) then
    local rv = preserve(self)
    for _,k in ipairs(f) do rv[k]=self[k] end
    return rv
  end
  return is.callable(f) and iter.map(self, make_filter(f)) or iter.map(self)
end

function iter.reduce(self, f, acc)
  assert(is.callable(f), 'invalid caller')
  return co.wrap(function()
    local it = iter(self)
    acc=acc or it()
    for v in it do
      acc = f(acc, v)
    end
    return acc
  end)()
end

function iter.find(self, it)
  if not is.callable(it) and type(it)~='nil' then
    local itit = it
    it = function(x) return itit==x end
  end
  return co.wrap(function()
    for v,k in iter(self) do
      if it(v, k) then return v,k end
    end
  end)()
end

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

return setmetatable(iter,{
__concat = function(r, it)
  if type(r)=='table' then
    return iter.collect(it, r)
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
  return setmetatable({it=iter.iter(it, to)}, getmetatable(iter))
end,
__iter = function(self, to)
  return iter.iter(self, to)
end,
__mul = function(self, to)
  if not is.callable(to) then to=function(v,k)
    if type(v)~='nil' and (mt(v).__mul or mt(to).__mul) then return v*to end
  end end
  return iter(iter.mul(self, to))
end,
__mod = function(self, to)
  if (not is.callable(to)) or mt(to).__mod then to=function(v,k)
--    return type(v)~='nil' and (mt(v).__mod or mt(to).__mod) and mt(to).__mod(v, to) or mt(v).__mod(v,to)
    return type(v)~='nil' and (mt(v).__mod or mt(to).__mod) and v%to
  end end
  return iter(iter.mod(self, to))
end,
})
