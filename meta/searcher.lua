require "compat53"

local conf = require "meta.conf"
local sub = require "meta.sub"

local searchpath = package.searchpath
local pkgpath = package.path
local sep = conf.sep

local function searcher(mod, need_error)
  assert(type(mod)=='string' and #mod>0)
  mod=sub(mod)
  if need_error then
    return searchpath(mod, pkgpath, sep)
  end
  return select(1, searchpath(mod, pkgpath, sep))
end

local function load(mod)
  assert(type(mod)=='string' and #mod>0)
  local p, err = searcher(mod, true)
  if p then return assert(loadfile(p)) end
  return err
end

if package.searchers[1]~=load then table.insert(package.searchers, 1, load) end

return searcher
