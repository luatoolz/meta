require "compat53"
local is={
  callable=require"meta.is.callable",
}
local pack, unpack =
  pack or table.pack,
  unpack or table.unpack

return function(f, h, ...)
  if not is.callable(f) then return nil end
  local res = pack(pcall(f, ...))
  if not res[1] then
    local e=res[2]
--    if e and e~=true then
--      if is.callable(h) then pcall(h, e) end
      return nil, e
--    end
  end
  return unpack(res, 2)
  end