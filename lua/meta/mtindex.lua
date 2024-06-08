require "compat53"

return function(self)
  assert(type(self) == 'table')
  local rv = self
  rv = getmetatable(rv) or {}
  local index = rawget(rv, '__index')
  while type(index)=='table' do
    rv=index
    index=rawget(rv, '__index')
  end
  return rv
end
