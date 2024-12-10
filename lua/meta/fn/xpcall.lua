require "compat53"
local callable, pack, unpack =
  require "meta.is.callable",
  table.pack or pack,
  table.unpack or unpack

return function(f, h, ...)
  if not callable(f) then return nil end
  local res = pack(pcall(f, ...))
  if not res[1] then
    local e=res[2]
    if e and e~=true then
      if h and callable(h) then pcall(h, e) end
      return nil, e
    end
  end
  return unpack(res, 2)
  end