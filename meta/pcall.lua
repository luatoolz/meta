require "compat53"

_ = require "meta.searcher"

local noerror = require "meta.noerror"

--local require = require "meta.require"("meta")
--local noerror = require ".noerror"

local function is_callable(f) return type(f) == 'function' or (type(f) == 'table' and type((getmetatable(f) or {}).__call) == 'function') end
--local function to_rv_err(ok, r) return ok and r or nil, (not ok) and r or nil end

return function(f, self)
  assert(type(self)=='table', "type(self) should be table, got " .. type(self))
  if is_callable(f) then
    return noerror(self, pcall(f, self))
  else
    return f
  end
--  return (is_callable(f)) and noerror(self, pcall(f, self)) or f
end

--[[
  if is_callable(f) then
    return noerror(self, pcall(f, self))
  else
    return f
  end
--]]
--  return is_callable(f) and error(self, pcall(f, self)) or f
--[[[
    if is_callable(f) then
      rv = error(pcall(f, self))
--      local ok, r = pcall(f, self)
--      rv = ok and r or nil
--      errors[self]=not ok and r or nil
    else
      rv = f
    end
    return rv
end
--]]

--[[
local errors =
return setmetatable(errors, {
  __call = function(self, o, f)
    assert(type(o)=='table', "type(o) should be table, got " .. type(o))
    local rv
  end,
})
--]]
