require 'meta.string'
local sep, msep, mdot = string.sep, string.msep, string.mdot
return function(mod, ...)
  if type(mod)=='table' then
    if getmetatable(mod) then return mod end
    return nil
  end
  if type(mod)=='string' then
    local key=sep:join(...)
    local mdots = mod:match(mdot)
    local mslash = mod:match(msep)
    if not (mdots and mslash) then
      mod = mod:gsub(mdot, sep)
    end
    return (key and table.concat({mod, key}, sep) or mod):null()
  end
end