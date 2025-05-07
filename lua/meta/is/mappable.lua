require "meta.gmt"
local checker = require 'meta.checker'
return checker({
  ['function'] = true,
  table = true,
  userdata = function(x) local gmt=getmetatable(x) or {}; return (gmt.__pairs or gmt.__ipairs or gmt.__iter or gmt.__next) and true or nil end,
}, type)