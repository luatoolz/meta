require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
local cache = require "meta.cache"
local is = require "meta.is"

return cache.log/{
  vars={protect=is.boolean, report=is.boolean, logger=is.func},
  call=function(self, ...)
    return (self.report or nil) and is.callable(self.logger) and self.logger(...)
  end,
  init=function(self)
    return {
      protect=true,
      report=false,
      logger=print,
    } end,
}