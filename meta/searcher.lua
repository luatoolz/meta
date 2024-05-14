require "compat53"

local conf = require "meta.conf"
local sub = require "meta.sub"
--local cache = require "meta.cache"

local searchpath = package.searchpath
local pkgpath = package.path
local loaded = package.loaded
local sep = conf.sep

local function noassert(x, ...) return x end
local function noload(p, e)
  if (not p) and e and need_error then return nil end
  return p end
local function searcher(mod) return noassert(searchpath(sub(mod), pkgpath, sep)) end
local function noloadfile(p) if type(p)=='string' then return noassert(loadfile(p)) end end
--local searchers = cache('searcher', nil, searcher)
local function load(mod) return loaded[mod] or loaded[sub(mod)] or noloadfile(searcher(mod)) end

local function contains(t, v)
  for i=1,#t do if t[i]==v then return true end end
  return false end

if not contains(package.searchers, load) then
  table.insert(package.searchers, 1, load) end

return searcher
