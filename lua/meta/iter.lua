require 'meta.math'
local iter = {}
local co = require 'meta.call'
local is = require 'meta.is'
local meta = require 'meta.lazy'
local fn, tab = meta({'fn', 'table'})
local mt, maxi, append = fn.mt, tab.maxi, tab.append
local op = require 'meta.op'

---------------------------------------------------------------------------------------------

-- adds index parameter as second argument, allowing seamless map/filter chains
local function addindex(i, x, ...) if type(x)~='nil' then
  if select('#', ...)>0 then return x, ... else
  if type(i)~='nil' and type(i)~='number' then return x, i
  else return x end end end end

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

local function bounds(self, neg) if type(self)=='table' then
  if neg==true or (type(neg)=='number' and neg<0) then
    return maxi(self), 1, type(neg)=='number' and neg or -1
  end
  return 1, maxi(self), type(neg)=='number' and neg or 1
end end

-- pairs iterations
function iter.ipairs(self, neg) if type(self)=='table' then
  local gmt = getmetatable(self) or {}
  local ipairz = gmt.__ipairs
  local max = maxi(self)
  if max and max>0 and (type(ipairz)=='nil' or ipairz==ipairs or type(neg)~='nil') then
    local a,b,inc = bounds(self, neg)
    return co.wrap(function() for i=a,b,inc do co.yieldok(self[i], i) end end)
  end
  ipairz=ipairz or ipairs
  return co.wrap(function() for i,v in ipairz(self) do co.yieldok(v, i) end end)
else return fn.null end end

-- __next convention
local function npairs(self, use_mt) if type(self)=='table' then
  if use_mt~=false then
    local gmt = getmetatable(self) or {}
    if gmt.__pairs then return pairs(self) end
    if gmt.__next then return gmt.__next, self end
  end
  return next,self
  end end

function iter.pairs(self, use_mt) if type(self)=='table' then
  return co.wrap(function() for k,v in npairs(self, use_mt) do co.yieldok(v, k) end end)
  else return fn.null end end

-- local filters for standard iterator
local function keys(v,k)        return k,nil end
local function key_not_num(v,k) return type(k)~='number' end
local function key_string(v,k)  return type(k)=='string' end

function iter.ivalues(self)     return iter.ipairs(self, false) end
function iter.svalues(self)     return iter.mod(iter.pairs(self, false), key_string) end
function iter.values(self)      return iter.mod(iter.pairs(self, false), key_not_num) end

function iter.ikeys(self)       return iter.mul(iter.ipairs(self, false), function(v,i) return i end) end
function iter.keys(self)        return iter.mul(iter.mod(iter.pairs(self, false), key_not_num), keys) end
function iter.skeys(self)       return iter.mul(iter.mod(iter.pairs(self, false), key_string), keys) end

-- generalized items iterator func
function iter.items(self)
  if type(self)=='nil' then return fn.null end
  local pairz = mt(self).__pairs or mt(self).__next
  if pairz then return iter.pairs(self) end
  return co.wrap(function()
    for v,i in iter.ivalues(self) do co.yieldok(v,i) end
    for v,k in iter.values(self) do co.yieldok(v,k) end
  end)
end

-- TODO: tuple limits, select, operations
function iter.tuple(...) return iter.ivalues({...}) end
function iter.args(...) local n,rv = select('#', ...),{...}; return (n==1 and type(rv[1])=='table') and rv[1] or rv end

-- collect iterator to table
function iter.collect(it, rv, recursive)
  rv=rv or {}
  for v,k in iter(it) do
    if type(k)=='number' and (is.like(iter,v) or is.func(v) or is.table(v)) and recursive then iter.collect(v, rv, recursive)
    else append(rv, v, type(k)~='number' and k or nil) end
  end return rv end

-- extract/get raw function iterator
function iter.it(self)
  if type(self)=='nil' then return fn.null end
  if is.like(iter,self) then return self.it end
  if type(self)=='function' then return self end
  local gmt = getmetatable(self)
  if (type(self)=='table' or type(self)=='userdata') and gmt then
    local iterf, pairz, ipairz = gmt.__iter, gmt.__pairs or gmt.__next, gmt.__ipairs
    if iterf then return iter.iter(iterf(self)) end
    if pairz then return iter.iter(iter.pairs(self)) end
    if ipairz then return iter.iter(iter.ipairs(self)) end
  end
  if type(self)=='table' then return iter.items(self) end
end

-- standard iterator convention - call with helper as second argument (func/callable)
function iter.iter(self, f)
  local it = iter.it(self)
  return (it and is.callable(f)) and iter.mul(it, f) or it
end

-- exec func for each element
function iter.each(self, f) f=f and co.pcaller(f) or fn.noop
  for v,k in iter(self) do f(v,k) end end

---------------------------------------------------------------------------------------------

-- reducer for iters
function iter.reduce(self, f, acc)
  assert(is.callable(f), 'invalid caller')
  local it = iter(self)
  acc=acc or it()
  for v in it do acc = f(acc, v) end
  return acc
end

-- TODO: add runners for find/reduce: max, min, etc
function iter.sum(self) return iter.reduce(self, function(a,b) return a+b end, 0) end
function iter.count(self) return iter.reduce(self, function(a,b) return a+1 end, 0) end

function iter.equal(self) return iter.reduce(self, function(a,b) if type(a)~='nil' and a==b then return a else return nil end end) and true or nil end
function iter.rawequal(self) return iter.reduce(self, function(a,b) if type(a)~='nil' and rawequal(a,b) then return a else return nil end end) and true or nil end

-- finder
function iter.find(self, f)
  assert(type(f)~='nil', 'invalid predicate')
  local ok=f
  if not is.callable(ok) and type(ok)~='nil' then
    ok = function(v,k) if f==v then return v,k end end
  end
  for v,k in iter(self) do if ok(v, k) then return v,k end end
end

---------------------------------------------------------------------------------------------

-- iter.mul: function composition
function iter.mul(self, f, recursive)
  f=f and co.pcaller(f)
  local yield = recursive and co.yieldokr or co.yieldok
  return f and co.wrap(function ()
    for v,k in iter.iter(self) do yield(addindex(k, f(v,k))) end
  end) or self
end

function iter.mod(self, to)
  return to and iter.mul(self, op.mod(to)) or self
end

---------------------------------------------------------------------------------------------

return setmetatable(iter,{
__concat = function(r, it) if type(r)=='table' and is.like(iter,it) then
  return iter.collect(it, r, true) end end,
__call = function(self, ...)
  local it, to = ...
  if type(it)=='nil' or not fn.n(...) then
    it = self.it
    if it then return it() else return nil,nil end end
  if is.like(iter,it) and not to then return it end
  return setmetatable({it=iter.it(it)}, getmetatable(iter))*to end,
__iter = function(self, to) return iter.iter(self, to) end,
__div  = function(self, to) return iter.mul(self, op.div(to))() end,
__mul  = function(self, to) return iter(iter.mul(self, op.mul(to), true)) end,
__mod  = function(self, to) return iter(iter.mul(self, op.mod(to), true)) end,
__name = 'iter',})