local mt, call, computed, loader =
  require "meta.mt.mt",
  require "meta.pcall",
  require "meta.mt.computed",
  require "meta.mt.loader"

return function(self, key)
  if type(self)=='table' and getmetatable(self) then
  return mt(self)[key]
    or call(mt(self).__preindex, self, key)
    or loader(self, key)
    or computed(self, key)
    or call(mt(self).__postindex, self, key)
  end end