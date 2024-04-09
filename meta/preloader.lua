require "compat53"
local loader = require "meta.loader"
local paths = require "paths"
return function(m)
  assert(type(m)=='string')
  local loader_dir = loader.path(m)
  assert(loader_dir)
  local o = loader(m)
  assert(o)
  if loader_dir then
    for it in paths.iterfiles(loader_dir) do
      if it ~= 'init.lua' then
        _ = o[it:gsub('%.lua$', '')]
      end
    end
    for it in paths.iterdirs(loader_dir) do
      _ = o[it]
    end
  end
  return o
end
