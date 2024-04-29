require "compat53"

_ = require "meta.searcher"

-- if toerror: return nil,err
-- return rv
return function(m, toerror)
  assert(type(m)=='string', 'prequire want string, got ' .. type(m))
  local ok, rv = pcall(require, m)
  if not ok then
		if toerror then
      return nil, rv
		else
			return nil
		end
  end
  if rv==true then return nil end
  return rv
end
