require 'meta.math'
local callable, checker =
  require "meta.is.callable",
  {}

local function eval(to, it)
  if callable(to) then
    return to(it)
  end
  if type(to)=='table' and not getmetatable(to) and #to>0 then
    local rv=it
    for i,f in ipairs(to) do
      rv=eval(f, rv)
    end
    return rv
  end
  if type(to)=='table' and not getmetatable(to) and type(next(to))~='nil' then
    return eval(to[it], it)
  end
  return to
end

local kpred, kdefault = {}, {}
local keys={[kpred]=true,[kdefault]=true}
return setmetatable(checker, {
__call=function(self, t, pred, default)
  if rawequal(self, checker) then
    if type(t)~='table' then return nil end
    t[kpred]=pred
    t[kdefault]=default
    return setmetatable(t, getmetatable(self))
  end
  return self[t]
end,
__div=function(self, it)
  if (not rawequal(self, checker)) and type(rawget(self, it))~='nil' then
    return setmetatable({[it]=rawget(self, it), [kpred]=rawget(self, kpred), [kdefault]=rawget(self, kdefault)}, getmetatable(self))
  end
end,
__index=function(self, it)
  if rawequal(self, checker) then return nil end
  if keys[it] then return rawget(self, it) end
  local pred, default = self[kpred], self[kdefault]

-- predicate call control
-- pred=callable - evaluation result

-- NO PREDICATE:
-- pred=nil      - arg value,                       -- HASH VALUE or EXECUTE callable, failed continue
-- pred==true    - map result, with continuation    -- HASH VALUE or EXECUTE callable
-- pred=false    - map result, no call (if callable)-- HASH RESULT AS IS
  local to
  if type(pred)=='nil' then pred=true end
  if type(pred)=='boolean' then
    return eval(rawget(self,it), pred and it or nil)
  end
  to=rawget(self, eval(pred,it))
  to=eval(to, it)
  if callable(default) then
    if type(to)~='nil' then to=eval(default, to) end else
    if type(to)=='nil' then to=default end
  end
  return to
end,
})