local no = require "meta.no"

return function(p, ...)
  return function(m, toerror)
    toerror=type(toerror)=='nil' and true or toerror
    assert(type(m)=='string', 'require want string, got ' .. type(m))
    if m:startswith('.') then m=no.sub(no.parent(p), m:lstrip('.')) end
    return no.require(m, true)
  end
end
