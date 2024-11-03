require "meta.string"
local is, checker, pkg =
  require "meta.mt.is",
  {},
  ...

return setmetatable(checker, {
__index=function(self, it)
  if it=='_' then return rawget(self, it) end
  local pred = self._
  local to = rawget(self, pred(it))
  if is.callable(to) then return to(it) end
  return to
end,
__call=function(self, t, pred)
  if is.empty(self) then
    if type(t)~='table' then return nil, '%s: no data table' % pkg end
    if pred and not is.callable(pred) then return nil, '%s: predicate uncallable' % pkg end
    t._=pred
    return setmetatable(t, getmetatable(self))
  end
  return self[t]
end,
__div=function(self, it)
  local t={}
  t._=self._
  t[it]=rawget(self, it)
  return setmetatable(t, getmetatable(self))
end,})