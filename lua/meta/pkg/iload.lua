require "meta.table"
local cache, log, xpcall =
  require "meta.cache",
  require "meta.cache.log",
  require "meta.xpcall"

return function(self, k)
  if not (type(self or nil)=='string' or (type(self or nil)=='table' and getmetatable(self or {}))) then return nil end
  if type(k)~='string' or #k==0 then return nil end
  local mod=self
  if type(mod)=='table' then mod=self .. nil end
  local load

  module=module or package.loaded['meta.module'] or package.loaded['meta/module']
  loader=loader or package.loaded['meta.loader'] or package.loaded['meta/loader']
  if loader then
    load=cache.existing.loader(mod) and cache.loader[mod] or loader(cache.instance[mod])
    if load then return load[k] end
  elseif module then
    load=module(mod)
    load=load.ok and load.loader
    if load then cache.loader[mod]=load; return load[k] end
  end
  if type(self)=='table' then load=self..k
  elseif type(self)=='string' then load=(self..'.')..k end
  if load then
    if not log.protect then return assert(require(load)) end
    return xpcall(require, log, load)
  end
end