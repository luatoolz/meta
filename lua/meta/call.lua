require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
local log
--local is = require "meta.is.basic"
local is = {callable = function(o) return (type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call) == 'function')) end}
-- pcall function with m or self as argument: f(m) or f(self)
-- return result or nil + save error
return function(f, ...)
  log=log or require "meta.log"
  local ok
  if is.callable(f) then
    if not log.protect then
      return f(...)
    end
    local res = table.pack(pcall(f, ...))
    ok = res[1]
    if not ok then
      local e=res[2]
      if e and e~=true then log(e); return end
    end
    return table.unpack(res, 2)
    end end
