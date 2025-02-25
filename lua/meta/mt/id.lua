local checker, mt =
  require 'meta.checker',
  require 'meta.mt.mt'

local uniq = checker({
  ['nil']=true, number=true, boolean=true, string=true,
  ['function']=true,CFunction=true,thread=true,
}, type)

return function(self)
  if uniq(self) then return self end
  local id = mt(self).__id
  if id then return id(self) end
  return nil
end