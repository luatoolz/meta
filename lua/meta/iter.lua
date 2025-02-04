require 'compat53'
require 'meta.gmt'
require 'meta.math'

local iter = {}

if (not package.loaded['meta.table']) and (not table.iters) and not table.maxi then
  assert(require 'meta.table')
end
table.iters = iter

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
  f=f and co.pcaller(f) or fn.noop
  return co.wrap(function ()
    for v,k in self do co.yieldok(addindex(k, f(v,k))) end
  end)
end

function iter.ipairs(self) if is.ipairable(self) then
  local gmt = getmetatable(self) or {}
  local ipairz = gmt.__pairs or gmt.__ipairs or ipairs
  local max = maxi(self)

  if ipairz~=ipairs or not max then return co.wrap(function()
    for i,v in ipairz(self) do co.yieldok(v, i) end
  end) end
  return co.wrap(function()
    for i=1,max do co.yieldok(self[i], i) end
  end)
else return function() end end end

function iter.pairs(self) if is.pairable(self) then
  return co.wrap(function()
    for k,v in pairs(self) do co.yieldok(v, k) end
  end)
else return function() end end end

function iter.ivalues(self) return iter.mul(iter.ipairs(self), function(v,i) return v end) end
function iter.ikeys(self)   return iter.mul(iter.ipairs(self), function(v,i) return i end) end
function iter.keys(self)    return iter.mul(iter.pairs(self),  function(v,k) if type(k)~='number' then return k,nil end end) end
function iter.values(self)  return iter.mul(iter.pairs(self),  function(v,k) if type(k)~='number' then return v,k end end) end

function iter.items(self)
  local pairz = mt(self).__pairs
  if pairz then return iter.pairs(self) end
  return co.wrap(function()
    for v in iter.ivalues(self) do co.yieldok(v) end
    for v,k in iter.values(self) do co.yieldok(v,k) end
  end)
end

function iter.tuple(...) return iter.ivalues({...}) end

function iter.collect(self, rv)
  rv=rv or preserve(self)
  for v,k in iter(self) do table.append(rv, v, k) end
  return rv
end

function iter.iter(self, values)
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
      if is.callable(values) then
        return iterf(self, values)
      else
        return iterf(self)
      end
    end
  end
  return iter(iter.items(self), values)
end

function iter.map(self, f)
  local rv = preserve(self)
  if not is.mappable(self) then return rv end
  return iter.collect(iter.mul(iter(self), f), rv)
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
  return iter.map(self, make_filter(f))
end

function iter.reduce(self, f, acc)
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
  return co.wrap(function()
    for v,k in iter(self) do
      if it(v, k) then return v,k end
    end
  end)()
end

return setmetatable(iter,{
__call = function(_, ...)
  return iter.iter(...)
end,
})