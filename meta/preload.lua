require "compat53"

_ = require "meta.searcher"
local paths = require "paths"
local loaders = require "meta.loaders"
local sub = require "meta.sub"
local path = require "meta.path"

-- self: string, table
local function preload(self, topreload, torecursive)
  if type(self)=='string' then self=sub(self) end
  assert(type(self)=='string' or type(self)=='table')
  self = type(self)=='table' and self or loaders[self]
  assert(type(self)=='table')
  if topreload then
    local dir = path(self)
    assert(dir, 'await string, got ' .. type(dir))
    if dir then
      for it in paths.iterfiles(dir) do
        if it ~= 'init.lua' then
          _ = self[it:gsub('%.lua$', '')]
        end
      end
      for it in paths.iterdirs(dir) do
        _ = preload(self[it], topreload, torecursive)
      end
    end
  end
  return self
end

return preload
