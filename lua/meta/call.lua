require 'meta.gmt'
local tuple = require 'meta.tuple'
local is = {
  callable = require 'meta.is.callable',
}
local n = tuple.n
local var = {
  protect = true,
  report = true,
  threads = 16,
  tracelevel = 2,
}
local cache = setmetatable({},{__mode='k',})

local call = {}
call.inspect = require 'inspect'
local boundary = "\n--------------------------------------------------------------------->\n"

local handler
handler = {
  reporter   = function(e, ...) if call.report then handler.printer(e, ...) end; return e, ... end,
  noreport = function(e) return e end,
  generic  = function(e, f)
    local coro = type(call.co(f))=='thread'
    local tt = coro and 'Coroutine' or 'Function'
    return string.format("%s failure: %s\n\n%s %s", tt, e, tt, f and debug.traceback(f) or debug.traceback())
  end,
--  error = function(e, f)
--    if not e then return e, f end
--    return nil, handler.reporter(handler.handler(e, f))
--  end,
  onerror = function(e,f,...)
    if f and type(f)~='function' or n(...) then
      e,f=boundary .. call.errors(e,f,...),nil
    end
    local coro = call.co(f)
    local tt = coro and type(coro) or (f and type(f)) or 'xpcall'
    local trace = f and call.traceback(f) or debug.traceback("", call.tracelevel)
    trace=trace:gsub('[^\n]+luassert[^\n]+',''):gsub('[^\n]+busted[^\n]+',''):gsub("[^\n]+xpcall[^\n]+",''):gsub('[\n]+','\n')
    return handler.reporter(string.format("%s error: %s, %s", tt, e, trace))
--    error(string.format("%s error: %s, %s", tt, e, trace))
  end,
  onignore = function() end,
  printer = print,
}
handler.handler = handler.onerror
handler.error = handler.onerror

-- debug.traceback()  for coroutine xpcall()
local function strip_traceback_header(traceback) return traceback:gsub("^.-\n", "") end
function call.traceback(coro, level)
  level = level or 0
  local parts = {}
  if coro then table.insert(parts, debug.traceback(coro)) end
  -- Note: for some reason debug.traceback needs a string to pass a level
  -- But if you pass a string it adds a newline
  table.insert(parts, debug.traceback("", 2 + level):sub(2))
  for i = 2, #parts do parts[i] = strip_traceback_header(parts[i]) end
  return table.concat(parts, "\n\t-- boundary --\n")
end

--------------------------------------------------------------------------------------------------------------

function call.tostring(...)
  local a = {...}
  for i,v in ipairs(a) do
    if type(v)=='nil' then        a[i]='nil'
    elseif type(v)=='table' and type(getmetatable(v))=='table' then
        a[i]='table[%s](%s)'^{getmetatable(v).__name, call(tostring,v) or 'FAIL{%d,%s}'^{#v,type(v[1])}}
    elseif type(v)=='table' and not getmetatable(v) then
      local m,x = #v>0 and #v or '...', type(v[1] or next(v))
      a[i]= 'table{%s}'^ (x=='nil' and '' or table.concat({m, x}, ', '))
    else a[i]=call(tostring,v) or ('FAIL type-%s'^{type(v)}) end end
  return table.concat(a, ' ')
end

local atom = {
  ['nil'] = true,
  string = true,
  number = true,
  boolean = true,
}

function call.errors(...)
  local r = {}
  for i=1,select('#', ...) do
    local v = select(i, ...)
    table.insert(r, atom[type(v)] and tostring(v) or call.tostring(v))
  end
  return #r>0 and table.concat(r, ': ') or 'ok?'
end

function call.catch(a,b) if a==nil and b then return call.error(b) end end
function call.error(...) return error(call.errors(...)) end
function call.assert(self, x, ...) if not x then return call.error(self, ...) end end

function call.log(...)
  local msg = call.tostring(...)
  call.printer(msg)
  return msg
end

local function name(self) return (getmetatable(self) or {}).__name end
function call.logindexer(self, k, v)
  if k~=nil and v~=nil then
    call.log('  %s[ %s ].%s == %s'^{name(self),self, call.tostring(k), call.tostring(v)})
  end
  return v
end

--[[ example call:
return function(self, k)
  if type(self)=='table' and type(k)~='nil' then
  return mt(self)[k]
    or itable(self, k)
    or report(self, '_( %s)'^{k}, computable(self, mt(self).__computable, k))
    or report(self, 'save( %s )'^{k}, save(self, k, computable(self, mt(self).__computed, k)))
  end return nil end
--]]

--------------------------------------------------------------------------------------------------------------

local co1 = coroutine or require "coroutine"

call.create  = co1.create
call.yield   = co1.yield
call.running = co1.running
call.status  = co1.status

call.pstatus = co1.status
call.presume = co1.resume

function call.xpcall(f, onerror, ...)
  if not is.callable(f) then return nil, 'arg not callable' end
  if not call.protect then return f(...) end
  return call.dispatch(xpcall(f, onerror, ...)) end

function call.pcall(f, ...)
--  if not is.callable(f) then return nil, 'arg not callable' end
  return call.xpcall(f, call.handler, ...) end

function call.quiet(f, ...)
--if is.callable(f) then
  return call.xpcall(f, call.onignore, ...) end

function call.xpresume(coro, onerror, ...)
  if call.status(coro)=='dead' then return nil, 'coroutine is dead' end
  return call.xpdispatch(coro, onerror, call.presume(coro, ...)) end

function call.resume(coro, ...)      return call.xpresume(coro, call.handler, ...) end
function call.resumeok(coro, x, ...) if x~=nil then return call.resume(coro, x, ...) end end
function call.yieldok(x, ...)        if x~=nil then call.yield(x, ...) end end
function call.yieldokr(x, ...) if x~=nil then
  if type(x)=='function' then
    while call.alive(x) do call.yieldok(x()) end
  else
    call.yieldok(x, ...)
  end
end end
function call.yielder(prod) if is.callable(prod) then for a in prod do call.yieldok(a) end end end

function call.xpdispatch(f, onerror, ok, x, ...)
  if ok then return x, ... end
  if is.callable(onerror) then return nil, onerror(x, f)
  else return nil, x end end

function call.dispatch(ok, x, ...)
  if ok then return x, ... end
  return nil, x end

function call.dispatch_returned(msg, ok, e, ...)
  if type(ok)=='nil' and e then call.log('nil', e, msg, table.pack(...)) end
  return ok, e, ...
end

-- call.wrap2 returns 2 values: callable runner (iterator) function + coroutine
function call.wrap2(f)
  do
    local coro = call.create(f)
    return function(...)
      if (not coro) or call.status(coro)=='dead' then return nil, 'coroutine is dead' end
      return call.resume(coro, ...)
    end, coro
  end
end

-- call.wrap returns only callable iterator
function call.wrap(f) return call.wrap2(f), nil end

-- extract coro from coro/runner
function call.co(f, i)
  if type(f)=='thread' then return f end
  if type(f)=='function' then
    local k,v = debug.getupvalue(f, 2)
    if k~='coro' then k,v = debug.getupvalue(f, 1) end
    if k=='coro' and type(v)=='thread' then return v end
  end return nil end

-- return coro status from coro/runner
function call.status(f) if f then
  local coro = call.co(f)
  return type(coro)=='thread' and call.pstatus(coro) or nil
end return nil end

-- check alive coro: accept suspended and normal, drop dead
function call.alive(f) return f and (call.status(f) or 'dead')~='dead' end

-- pcall protector
function call.pcaller(f)
  return function(...)
    return call.pcall(f, ...)
  end end
call.caller = call.pcaller

-- nested callers
function call.lift2(self, f) if is.callable(self) then
  return is.callable(f) and function(...) return f(self(...)) end or self end; return tuple.noop end

function call.lift(a,b,...) local new=call.lift2(a,b); return n(...) and call.lift(new, ...) or new end

-- thread executor
function call.run(wr, ...)
  local coro = call.co(wr)
  while call.alive(coro) do call.resume(coro, ...) end end

-- call.pool(producer, worker, [n])
-- producer - syncronized data source function, mandatory
--   worker - function sourcing one producer, mandatory
--   n      - #threads, optional, default: call.threads, 16
-- return: call.wrap, accepting args: producer
--
-- recursive parallel map/filter/reduce with iter:
--   local cp = call.pool(...)
--
--   iter:  iter(cp, f)
--  __mul:  iter(cp) * callee
--  __mod:  iter(cp) % pred
-- reduce:  iter.reduce(cp, red)
--   find:  iter.find(cp, pred)
--
-- stackable ok: call.pool(call.pool(a), w)
--
-- NOTE: call.yieldok yields only non-null values
--
function call.pool(producer, worker, j) do
  assert(producer, 'producer required')
  worker=worker or call.yielder
  return call.wrap(function()
    local thread = {}
    for i=1,j or call.threads do table.insert(thread, call.create(worker)) end
    while #thread>0 do
      for i=1,#thread do
        local coro = thread[i]
        local status = call.status(coro)
        if status=='suspended' or status=='normal' then
          call.yieldok(call.resume(coro, producer))
        end
        if status=='dead' then thread[i]=nil end
      end
    end
  end)
end end

-- call.protect = boolean; use pcall
-- call.report  = boolean; port errors to log printer
-- call.printer = callable; log printer
setmetatable(call, {
__name = 'call',
__call = function(self, f, ...)
  local o,i=...,1
  if type(f)=='string' and type(o)=='table' then f,i=o[f],2 end
  if is.callable(f) then return self.pcall(f, select(i, ...)) end
end,
__index = function(self, k) return var[k] or handler[k] end,
__newindex = function(self, k, v)
  if k=='printer'     then handler[k] = is.callable(v) and v or print; return end                                     -- output function (print)
  if k=='threads'     then if type(v)=='number' then var.threads=v end; return end                                    -- default #threads (16)
  if k=='tracelevel'  then if type(v)=='number' then var.tracelevel=v end; return end                                 -- default #traceback level (2)
  if k=='protect'     then if type(v)=='boolean' or type(v)=='nil' then var.protect=v and true or nil end; return end -- switch protect on/off (on)
  if k=='report'      then if type(v)=='boolean' or type(v)=='nil' then var.report=v  and true or nil end; return end -- switch report errors on/off (on)
  if k=='handler'     then handler[k] = v; return end
  error(string.format('call: wrong key: %s',k))
end,
})

rawset(call, 'method', setmetatable({},{
__call=function(self, f, ...) return call.pcall(f, ...) end,
__index=function(self, xname)
  return function(o, ...)
    local f = (getmetatable(o) or {})[xname] or (o or {})[xname]
    if f then cache[f]=xname end
    if f and o then return call.pcall(f, o, ...) end
  end
end,}))

return call