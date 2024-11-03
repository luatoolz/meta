require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
local pkg = ...
local is = {
  callable=function(o) return type(o) == 'function' or (type(o) == 'table' and type((getmetatable(o) or {}).__call) == 'function') end,
  table=function(x) return type(x)=='table' end,
  empty=function(x) return type(x)=='table' and type(next(x))=='nil' end,
}
local checker={}

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
    if not is.table(t) then return nil, '%s: no data table' % pkg end
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