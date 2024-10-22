require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"

local pkg     = ...
local mod, name = pkg:meta()
local _ = mod
_ = name
--match('^([^/.]+)[/.](.+)$')
--local mod, name = pkg:match('^([^/.]+)[/.](.+)$')
--local name    = string.match(..., '^[^/.]+[/.](.+)$')

local cache   = require "meta.cache"
local module  = cache.module
local join    = string.sep:joiner()

return cache.ordered.root/{
normalize=string.matcher('^[^/.]+'),
try=string.matcher('^[^/.]+'),
call=function(self, ...)
  if not cache.normalize.module then require "meta.module" end
    local rt={}
    for _,parent in ipairs(self) do
      local rv = module(join(parent, ...))
      rv=rv and rv.load
      if rv then table.insert(rt, rv) end
    end
    assert(#rt==0 or #rt==1, '%s: multiple predicates' % pkg)
    return #rt>0 and rt or {}
end} + 'meta'