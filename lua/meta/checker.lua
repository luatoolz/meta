require "meta.string"
local is, checker, pkg =
  require "meta.mt.is",
  {},
  ...

local kpred, kdefault = {}, {}
local keys={[kpred]=true,[kdefault]=true}
return setmetatable(checker, {
__call=function(self, t, pred, default)
  if rawequal(self, checker) then
    if type(t)~='table' then return nil, '%s: no data table' % pkg end
    if pred and not is.callable(pred) then return nil, '%s: predicate uncallable' % pkg end
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
  if rawequal(self, checker) then return end
  if keys[it] then return rawget(self, it) end
  local pred, default = self[kpred], self[kdefault]
  local to = rawget(self, pred(it))
  if is.callable(to) then to=to(it) end
  if is.callable(default) then to=default(to) else
    if type(to)=='nil' then to=default end
  end
  return to
end,
})