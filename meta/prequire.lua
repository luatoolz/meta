require "compat53"

return function(m)
  assert(type(m)=='string', 'prequire want string, got ' .. type(m))
  local ok, rv = pcall(require, m)
  if not ok then
    return nil, rv
  end
  if rv==true then return nil end
  return rv
end
