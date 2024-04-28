require "compat53"

return function(m, tosave, toprotect)
  return setmetatable({}, { __index = function(self, key)
    assert((type(key) == 'string' and #key > 0) or type(key) == 'number')
    local f = m[key]
    local callable = type(f)=='function' or (type(f)=='table' and type((getmetatable(f) or {}).__call) == 'function')
    if not callable then return f end
    local save = tosave and function(x) rawset(self, key, x); return x end or function(x) return x end
    if toprotect then
      local ok, rv = pcall(f, self)
      f = ok and rv or nil
      if not ok then self.err=rv end
    else
      f = f(self)
    end
    return save(f)
  end })
end
