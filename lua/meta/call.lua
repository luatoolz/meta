require 'compat53'
local pcall, error = pcall, error
local is = {
  callable = require 'meta.is.callable',
}
local this = {}
local var = {
  protect = true,
  report = false,
}
local handler = {
  noreport = function(e, f) return e end,
  generic = function(e, f)
    local coro = type(this.co(f))=='thread'
    local tt = coro and 'Coroutine' or 'Function'
    local msg = string.format("%s failure: %s\n\n%s %s", tt, e, tt, f and debug.traceback(f) or debug.traceback())
    if coro then error(msg) end
    return msg
  end,
}
handler.handler = handler.noreport
handler.handler_co = function(msg, f)
  if var.report then
    msg = handler.generic(msg, f)
  end
  return handler.handler(msg)
end

local function strip_traceback_header(traceback)
  return traceback:gsub("^.-\n", "")
end

function this.traceback(coro, level)
  level = level or 0

  local parts = {}

  if coro then
    table.insert(parts, debug.traceback(coro))
  end

  -- Note: for some reason debug.traceback needs a string to pass a level
  -- But if you pass a string it adds a newline
  table.insert(parts, debug.traceback("", 2 + level):sub(2))

  for i = 2, #parts do
    parts[i] = strip_traceback_header(parts[i])
  end

  return table.concat(parts, "\n\t-- boundary --\n")
end

function this.dispatch(f, handler_func, status, maybe_err, ...)
  if not status then
    if maybe_err and maybe_err~=true then
      if is.callable(handler_func) then
        return nil, handler_func(maybe_err, f)
      else
        return nil, maybe_err
      end
    end
  end
  return maybe_err, ...
end

function this.xpcall(f, handler_func, ...)
  if not is.callable(f) then return nil end
  return this.dispatch(f, handler_func, pcall(f, ...))
end

function this.pcall(f, ...)
  if not this.protect then
    return f(...)
  end
  return this.xpcall(f, this.handler, ...)
end

-- coroutine
local co1 = coroutine or require "coroutine"

this.create = co1.create
this.yield = co1.yield
this.running = co1.running

this.pstatus = co1.status
this.presume = co1.resume

function this.xpresume1(coro, handler_func, ...)
  return this.dispatch(coro, handler_func, this.presume(coro, ...))
end

function this.xpresume(co, handler_func, ...)
  if this.pstatus(co)=='dead' then return nil, this.handler(handler.generic('coroutine is dead')) end
  return this.dispatch(co, nil, pcall(this.xpresume1, co, handler_func, ...))
end

function this.resume(co, ...)
  if this.pstatus(co)=='dead' then return nil, this.handler(handler.generic('coroutine is dead')) end
  return this.dispatch(co, this.handler, pcall(this.xpresume1, co, handler.generic, ...))
end

function this.wrap(f)
  do
    local co = this.create(f)

    return function(...)
      return this.resume(co, ...)
    end
  end
end

function this.co(f)
  if type(f)=='thread' then return f end
  if type(f)=='function' then
    local k,v = debug.getupvalue(f, 2)
    if k=='co' and type(v)=='thread' then return v end
  end
  return nil
end

function this.status(f)
  local coro = this.co(f)
  return type(coro)=='thread' and this.pstatus(coro) or nil
end

function this.pcaller(f)
  return function(...)
    return this.pcall(f, ...)
  end
end

function this.caller(f)
  return this.pcaller(f)
end

-- call.protect = true/false; run with pcall or raw
-- call.report = boolean/callable
return setmetatable(this, {
__call = function(self, f, ...)
  return self.pcall(f, ...)
end,
__index = function(self, k)
  return var[k] or handler[k]
end,
__newindex = function(self, k, v)
  if k=='protect' then if type(v)=='boolean' or type(v)=='nil' then var.protect=v and true or nil end; return end
  if k=='handler' then handler[k] = (self.report and is.callable(v)) and v or handler.noreport; return end
  if k=='report' then
    if is.callable(v) or type(v)=='boolean' or type(v)=='nil' then
      var.report=v and true or nil
      if v and not is.callable(v) then v=print end
      self.handler = function(e, f)
        local report = v
        report(e)
        return e
      end
    end
    return
  end
  error(string.format('call: wrong key: %s',k))
end,
})