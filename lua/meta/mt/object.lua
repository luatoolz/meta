local cache, pcall, computed =
  require "meta.cache",
  require "meta.pcall",
  require "meta.mt.computed"

return function(self, key)
  assert(type(self)=='table')
  return pcall(getmetatable(self).__preindex, self, key)
    or computed(self, key)
    or (type(key)=='string' and (cache.loader[self] or cache.loader[getmetatable(self)] or {})[key] or nil)
    or pcall(getmetatable(self).__postindex, self, key)
  end