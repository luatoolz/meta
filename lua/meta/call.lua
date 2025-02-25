require 'compat53'
require 'meta.gmt'
local xpcall, pcall, error = xpcall, pcall, error
local is = {
  callable = require 'meta.is.callable',
}
local this = {}
local co = this
local var = {
  protect = true,
  report = true,
  threads = 16,
}
local handler
handler = {
  reporter   = function(e, ...) if var.report then handler.printer(e, ...) end; return e, ... end,
  noreport = function(e) return e end,
  generic  = function(e, f)
    local coro = type(this.co(f))=='thread'
    local tt = coro and 'Coroutine' or 'Function'
    return string.format("%s failure: %s\n\n%s %s", tt, e, tt, f and debug.traceback(f) or debug.traceback())
  end,
  error = function(e, f)
    if not e then return e, f end
    return nil, handler.reporter(handler.generic(e, f)) end,
  printer = print,
}
handler.handler = handler.generic

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

function this.dispatch(f, handlerf, status, maybe_err, ...)
  if not status then
    if maybe_err and maybe_err~=true then
      if is.callable(handlerf) then
        return nil, handlerf(maybe_err, f)
      else
        return nil, maybe_err
      end
    end
  end
  return maybe_err, ...
end

function this.xpcall(f, handlerf, ...)
  if not is.callable(f) then return end
  return this.dispatch(f, this.reporter, xpcall(f, handlerf, ...))
end

function this.pcall(f, ...)
  if not this.protect then
    return f(...)
  end
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

function this.error(msg, f)
  return nil, this.reporter(msg, f)
end

function this.yieldok(x, ...) if type(x)~='nil' then this.yield(x, ...) end end

function this.xpresume1(coro, handlerf, ...)
  return this.dispatch(coro, handlerf, this.presume(coro, ...))
end

function this.xpresume(coro, handlerf, ...)
  if this.status(coro)=='dead' then return nil, this.reporter(this.generic('coroutine is dead')) end
  return this.dispatch(coro, this.reporter, pcall(this.xpresume1, coro, handlerf, ...))
end

function this.resume(coro, ...)
  if this.status(coro)=='dead' then return nil, this.reporter(this.generic('coroutine is dead')) end
  return this.dispatch(coro, this.reporter, pcall(this.xpresume1, coro, this.handler, ...))
end

function this.resumeok(coro, x, ...) if x then
  return co.resume(coro, x, ...)
end end

function this.wrap2(f)
  do
    local coro = this.create(f)
    return function(...)
      if (not coro) or co.status(coro)=='dead' then return nil end
      return this.resume(coro, ...)
    end, coro
  end
end

function this.wrap(f)
  local r = this.wrap2(f)
  return r
end

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

function this.caller(f)
  return this.pcaller(f)
end

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
function this.pool(producer, worker, n) do
  assert(producer, 'producer required')
  assert(worker, 'worker required')
  return co.wrap(function()
    local thread = {}
    for i=1,n or this.threads do table.insert(thread, co.create(worker)) end
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

-- call.protect = boolean; use pcall
-- call.report  = boolean; port errors to log printer
-- call.printer = callable; log printer
return setmetatable(this, {
__call = function(self, f, ...) return self.pcall(f, ...) end,
__index = function(self, k) return var[k] or handler[k] end,
__newindex = function(self, k, v)
  if k=='printer' then handler[k] = is.callable(v) and v or print; return end                                     -- output function (print)
  if k=='threads' then if type(v)=='number' then var.threads=v end; return end                                    -- default #threads (16)
  if k=='protect' then if type(v)=='boolean' or type(v)=='nil' then var.protect=v and true or nil end; return end -- switch protect on/off (on)
  if k=='report'  then if type(v)=='boolean' or type(v)=='nil' then var.report=v  and true or nil end; return end -- switch report errors on/off (on)
  error(string.format('call: wrong key: %s',k))
end,
})