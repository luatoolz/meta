require "compat53"

_ = require "meta.searcher"

-- pcall handler
--local errors = 
return setmetatable({}, {
  __mode = "k",
  __call = function(self, k, ok, r)
    local rv
    if ok then rv=r else self[k]=r; end -- error(string.format('error (%s) %s', type(r), r)) end
--    local rv, err = (ok) and r else nil, (not ok) and r else nil
--    self[k]=(not ok) and r or nil
    return rv
  end,
})

--return errors

--[[
local errors =  setmetatable({}, {
  __mode = "k",
  __call = function(self, k)
-- return assert(...)-like handler
    return function(v, err)
      if err then self[k]=err end
      return v
    end
-- return pcall handler
    return function(ok, r)
      local rv, err = ok and r or nil, (not ok) and r or nil
      self[k]=err
      return rv
    end
  end,
})
--]]
