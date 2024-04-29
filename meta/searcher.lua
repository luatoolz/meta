require "compat53"

local conf = require "meta.conf"
local sub = require "meta.sub"

local searchpath = package.searchpath
local pkgpath = package.path
local sep = conf.sep
local cache = {}

local function searcher(mod, need_error)
  assert(type(mod)=='string' and #mod>0)
  mod=sub(mod)
	local p = cache[mod]
	if not p then
		local e
    p,e = searchpath(mod, pkgpath, sep)
	  if (not p) and e and need_error then return p, e end
    if p then cache[mod]=p end
  end
	return p
end

local function load(mod)
  assert(type(mod)=='string' and #mod>0)
  local p, err = searcher(mod, true)
  if p then return assert(loadfile(p)) end
  return nil, err
end

if package.searchers[1]~=load then table.insert(package.searchers, 1, load) end

return searcher
