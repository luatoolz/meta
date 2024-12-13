require "compat53"
local is = require "meta.mt.is"
local log = require "meta.log"
return function(f, h, ...)
  if not is.callable(f) then return nil end
  if not log.protect then
    return f(...)
  end
  local res = table.pack(pcall(f, ...))
  if not res[1] then
    local e=res[2]
    if e and e~=true then
      h=h or log
      if is.callable(h) then pcall(h, e) end
      return nil, e
    end
  end
  return table.unpack(res, 2)
end