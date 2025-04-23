local xpcall, pcall, error = xpcall, pcall, error
require 'compat53'
require 'meta.gmt'
_,_ = pcall, xpcall
local is = {
  callable = require 'meta.is.callable',
}
local n = require 'meta.fn.n'
local this = {}
local co = this
local var = {
  protect = true,
  report = true,
  threads = 16,
}
local handler
handler = {
  reporter   = function(e, ...) if this.report then handler.printer(e, ...) end; return e, ... end,
  noreport = function(e) return e end,
  generic  = function(e, f)
    local coro = type(this.co(f))=='thread'
    local tt = coro and 'Coroutine' or 'Function'
    return string.format("%s failure: %s\n\n%s %s", tt, e, tt, f and debug.traceback(f) or debug.traceback())
  end,
--  error = function(e, f)
--    if not e then return e, f end
--    return nil, handler.reporter(handler.handler(e, f))
--  end,
  onerror = function(e,f,...)
    if f and type(f)~='function' or n(...) then e,f="\n--------------------------------------------------------------------->\n"..string.errors(e,f,...),nil end
    local coro = this.co(f)
    local tt = coro and type(coro) or (f and type(f)) or 'xpcall'
    local trace = f and this.traceback(f) or debug.traceback("", 2)
    trace=trace:gsub('[^\n]+luassert[^\n]+',''):gsub('[^\n]+busted[^\n]+',''):gsub("[^\n]+xpcall[^\n]+",''):gsub('[\n]+','\n')
    return handler.reporter(string.format("%s error: %s, %s", tt, e, trace))
  end,
  printer = print,
}
handler.handler = handler.onerror
handler.error = handler.onerror

local function strip_traceback_header(traceback) return traceback:gsub("^.-\n", "") end
function this.traceback(coro, level)
  level = level or 0
  local parts = {}
  if coro then table.insert(parts, debug.traceback(coro)) end
  -- Note: for some reason debug.traceback needs a string to pass a level
  -- But if you pass a string it adds a newline
  table.insert(parts, debug.traceback("", 2 + level):sub(2))
  for i = 2, #parts do parts[i] = strip_traceback_header(parts[i]) end
  return table.concat(parts, "\n\t-- boundary --\n")
end

function this.xpdispatch(f, handlerf, status, maybe_err, ...)
  if not status then
    if is.callable(handlerf) then
      return nil, handlerf(maybe_err, f)
    else
      return nil, maybe_err
    end
  end
  return maybe_err, ...
end
function this.dispatch(status, maybe_err, ...)
  if status then
    return maybe_err, ...
  else
    return nil, maybe_err
  end
end

function this.xpcall(f, onerror, ...)
  if is.callable(f) then
    return this.dispatch(xpcall(f, onerror, ...))
  else
    return nil, 'uncallable argument: ' .. type(f)
--    return nil, onerror('uncallable argument: ' .. type(f))
  end
end

function this.pcall(f, ...)
  if is.callable(f) and not this.protect then return f(...) end
  return this.xpcall(f, this.handler, ...)
end

-- coroutine
local co1 = coroutine or require "coroutine"

this.create  = co1.create
this.yield   = co1.yield
this.running = co1.running
this.status  = co1.status

this.pstatus = co1.status
this.presume = co1.resume

function this.tostring(...)
  local a = {...}
  for i,v in ipairs(a) do
    if type(v)=='nil' then        a[i]='(nil)'
    elseif type(v)=='table' and type(getmetatable(v))=='table' then
        a[i]='table[%s]'^(getmetatable(v).__name or tostring(v))
    elseif type(v)=='table' and not getmetatable(v) then
      local m,x = #v>0 and #v or '...', type(v[1] or next(v))
      a[i]= 'table{%s}'^ (x=='nil' and '' or table.concat({m, x}, ', '))
    else a[i]=tostring(v) end end
  return table.concat(a, ', ')
end

function this.log(...)
  local msg = this.tostring(...)
  this.printer(select('#', ...), msg)
  return msg
end

function this.yieldok(x, ...) if type(x)~='nil' then this.yield(x, ...) end end

function this.xpresume(coro, onerror, ...)
  if this.status(coro)=='dead' then return nil, 'coroutine is dead' end
  return this.xpdispatch(coro, onerror, this.presume(coro, ...))
end

function this.resume(coro, ...) return this.xpresume(coro, this.handler, ...) end
function this.resumeok(coro, x, ...) if x then return co.resume(coro, x, ...) end end

function this.wrap2(f)
  do
    local coro = this.create(f)
    return function(...)
      if (not coro) or co.status(coro)=='dead' then return nil, 'coroutine is dead' end
      return this.resume(coro, ...)
    end, coro
  end
end

function this.wrap(f) return this.wrap2(f), nil end

function this.co(f, i)
  if type(f)=='thread' then return f end
  if type(f)=='function' then
    local k,v = debug.getupvalue(f, 2)
    if k~='coro' then k,v = debug.getupvalue(f, 1) end
    if k=='coro' and type(v)=='thread' then return v end
  end
  return nil
end

function this.status(f)
  local coro = this.co(f)
  return type(coro)=='thread' and this.pstatus(coro) or nil
end

function this.alive(f)
  return f and this.status(f)~='dead'
end

function this.pcaller(f)
  return function(...)
    return this.pcall(f, ...)
  end
end
this.caller = this.pcaller

-- execute
function this.run(wr, ...)
  local coro = this.co(wr)
  assert(coro, 'thread required')
  while co.status(coro) ~= "dead" do
    co.resume(coro, ...)
  end
end

-- co.pool(producer, worker, [n])
-- producer - syncronized data source function, mandatory
--   worker - function sourcing one producer, mandatory
--   n      - #threads, optional, default: co.threads, 16
-- return: co.wrap, accepting args: producer
--
-- recursive parallel map/filter/reduce with iter:
--   local cp = co.pool(...)
--
--   iter:  iter(cp, f)
--  __mul:  iter(cp) * callee
--  __mod:  iter(cp) % pred
-- reduce:  iter.reduce(cp, red)
--   find:  iter.find(cp, pred)
--
-- stackable ok: co.pool(co.pool(a), w)
--
-- NOTE: co.yieldok yields only non-null values
--
function this.pool(producer, worker, j) do
  assert(producer, 'producer required')
  assert(worker, 'worker required')
  return co.wrap(function()
    local thread = {}
    for i=1,j or this.threads do table.insert(thread, co.create(worker)) end
    while #thread>0 do
      for i=1,#thread do
        local coro = thread[i]
        local status = co.status(coro)
        if status=='suspended' or status=='normal' then
          co.yieldok(co.resume(coro, producer))
        end
        if status=='dead' then thread[i]=nil end
      end
    end
  end)
end end

local div = '\n-----------------------------------------------\n'
function this:onfail(msg)
  local function ok(a,b) return type(a)~='nil' and a~=false end
  local function caller(...) return self.pcall(...) end
  local function concat_errors(a,b) return div .. 'ERROR: ' .. tostring(a) .. ', with nested error:\n' .. tostring(b) .. div end
  return function(...)
    local function result(x,y)
      if ok(x,y) then return x end
      return error(concat_errors(msg, y), 2)
    end
    return result(caller(...))
  end
end

local function xpok(external_msg,a,b,...)
  if b and not a then error(tostring(external_msg) .. ': ' .. tostring(b)) end
  return a,b,...
end
function this.xpok(f, external_msg, ...)
  return xpok(external_msg, this.pcall(f, ...))
end

-- call.protect = boolean; use pcall
-- call.report  = boolean; port errors to log printer
-- call.printer = callable; log printer
return setmetatable(this, {
__name = 'call',
__call = function(self, f, ...) return self.pcall(f, ...) end,
__index = function(self, k) return var[k] or handler[k] end,
__newindex = function(self, k, v)
  if k=='printer' then handler[k] = is.callable(v) and v or print; return end                                     -- output function (print)
  if k=='threads' then if type(v)=='number' then var.threads=v end; return end                                    -- default #threads (16)
  if k=='protect' then if type(v)=='boolean' or type(v)=='nil' then var.protect=v and true or nil end; return end -- switch protect on/off (on)
  if k=='report'  then if type(v)=='boolean' or type(v)=='nil' then var.report=v  and true or nil end; return end -- switch report errors on/off (on)
  if k=='handler' then handler[k] = v; return end
  error(string.format('call: wrong key: %s',k))
end,
})