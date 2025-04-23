require 'meta.string'
local iter = require 'meta.iter'
return setmetatable({}, {
__add = function(self, k)
print(' iqueue add', k)
  rawset(self, k, false)
--  self[k]=false
  return self
end,
__newindex=function(self, k, v)
  print(' iqueue set', k, v)
  rawset(self, k, v)
end,
__tostring=function(self)
  return 'iq(' .. table.concat({}..iter(self), ' :: ') .. ')'
end,
__sub = function(self, k)
print(' iqueue sub', k)
  rawset(self, k, nil)
  return self
end,
})