require "compat53"

_ = require "meta.searcher"

--    local prequire = meta.prequire("meta.")   -- use '.' at end, or '/' divider loading module with dotted name
--    local loader = prequire(".loader")        -- use '.' at beginning, or '/' ...

-- if toerror: return nil,err
-- return rv
local function prequirer(pa, toerr)
  local p = pa
  assert(type(p) == 'string')
  assert(#p > 0)
  local endot = string.sub(p, -1)
  if (endot ~= '/' and endot ~= '.') then endot = nil end

  local pr = function(m, toerror)
    assert(type(m) == 'string', 'prequire want string, got ' .. type(m))
    if endot then
      local bdot = string.sub(m, 1, 1)
      assert(bdot == '.' or bdot == '/')
      m = string.sub(m, 2)
      m = string.sub(p, 1, -2) .. bdot .. m
    end
    local ok, rv = pcall(require, m)
    if not ok then
      if toerror then
        return nil, rv
      else
        return nil
      end
    end
    if rv == true then return nil end
    return rv
  end

  if not endot then return pr(p, toerr) end
  return pr
end

return prequirer
