require "meta.table"
local mcache, is =
  require "meta.mcache",
  require "meta.mt.is"

return mcache.log/{
  vars={protect=is.boolean, report=is.boolean, logger=is.func},
  call=function(self, ...)
    local idx=(select('#', ...)>0 and type(select(1, ...))~='nil') and 1 or 2
    return (self.report or os.getenv('DEBUG') or nil) and is.callable(self.logger) and self.logger(select(idx, ...))
  end,
  init=function(self)
    return {
      protect=true,
      report=false,
      logger=print,
    } end,
}