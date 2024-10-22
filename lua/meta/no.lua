require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
local log   = require "meta.log"
local cache = require "meta.cache"
local paths = require "paths"
local root = require "meta.cache.root"
local is = require "meta.is"
local has = is.has
local mt = require "meta.mt"
local seen = require "meta.seen"
local iter = table.iter
local no = {}

local sub

local sep, msep, mdot, mmultisep = string.sep, string.msep, string.mdot, string.mmultisep
local searchpath, pkgpath, pkgloaded = package.searchpath, package.path, package.loaded
local pkgdirs
local _ = pkgloaded

-- computable functions ---------------------------------------------------------------------------------------------------------------------
function no.object(self, key)
  assert(type(self)=='table')
  return no.call(mt(self).__preindex, self, key)
    or no.computed(self, key)
    or (type(key)=='string' and (cache.loader[self] or cache.loader[getmetatable(self)] or {})[key] or nil)
    or no.call(mt(self).__postindex, self, key)
  end

function no.computed(self, key)
  assert(type(self)=='table')
  if type(key)~='string' then return end
  return mt(self)[key]
    or no.computable(self, mt(self).__computable, key)
    or table.save(self, key, no.computable(self, mt(self).__computed, key))
  end

function no.computable(self, t, key)
  if type(t)=='nil' or (type(t)=='table' and not next(t)) or type(key)=='nil' then return nil end
  assert((type(key)=='string' and #key > 0) or type(key) == 'number', 'no.computable: want key string/number, got ' .. type(key))
  assert(type(t)=='table', 'no.computable: want table, got ' .. type(t))
  return no.call(rawget(t, key), self)
  end

-- helper functions ---------------------------------------------------------------------------------------------------------------------

function no.join(...)
  return (sep:join(table.unpack(table{...} * string.smatcher('^%s*(.-)%s*$'))) or ''):gsub(mmultisep, sep):gsub('%s$'%msep, ''):null()
  end

function no.strip(x, ...)
  if type(x)=='string' then
    if select('#', ...)==0 then return no.strip(x, '%/?init%.lua$', '.lua$') end
    for i=1,select('#', ...) do
      local b = select(i, ...)
      if type(b)=='string' or type(b)=='function' then
        x = x:gsub(b, '', 1)
      end
    end
    end
  return x~= '' and x or nil
  end

-- meta/loader.lua -> meta
-- meta/loader/init.lua -> meta
-- meta/loader -> meta
function no.parent(x) return
  no.strip(no.strip(no.sub(x)), '[^/]*$', '%/?$')
  end

-- meta/loader.lua -> loader
-- meta/loader/init.lua -> loader
-- meta/loader -> loader
function no.basename(x) return
  no.strip(no.strip(no.sub(x), '%/?init%.lua$', '^.*%/'))
  end

function no.to(o, mod, key)
  if type(mod)~='string' then return nil end
  if type(key)~='string' then key=nil end

  local mdots = mod:match(mdot)
  local mslash = mod:match(msep)

  if key and key:match(mdot) then o=sep end
  if not (mdots and mslash) then
    mod = mod:gsub(mdot, o):gsub(msep, o)
  end
  return key and table.concat({mod, key}, o) or mod
  end

function no.sub(mod, ...)
  if type(mod)=='table' then return mod end
  if type(mod)=='string' then
    mod=no.strip(mod)
    mod=no.to(sep, mod)
    for i=1,select('#', ...) do
      mod=no.to(sep, mod, select(i, ...))
    end
    if mod~='' then return mod end
  end end

function no.assert(x, e, ...)
  if e and e~=true then log(e) end; return x end --, e end

-- pcall function with m or self as argument: f(m) or f(self)
-- return result or nil + save error
function no.call(f, ...)
  local ok
  if is.callable(f) then
    if not log.protect then
      return f(...)
    end
    local res = table.pack(pcall(f, ...))
    ok = res[1]
    if not ok then
      local e=res[2]
      if e and e~=true then log(e); return end
    end
    return table.unpack(res, 2)
    end end

-- fs/path functions ---------------------------------------------------------------------------------------------------------------------

function no.ismodule(...)
  if select('#', ...)>0 then
  local p = no.join(...)
  return (table(p, no.join(p, 'init'))*string.formatter('%s.lua') % is.file)[1]
  end end

-- loader functions ---------------------------------------------------------------------------------------------------------------------

function no.pkgdirs()
  return cache.ordered.pkgdirs .. ((table() .. (package.path:gsub('(' .. msep .. '?%?[^;]+)', ''):gmatch("([^;]+)"))) % is.dir)
  end

-- return module dirs for all pkg dirs
function no.scan(mod)
  if type(mod)~='string' or #mod==0 then mod=nil end
  mod=no.sub(mod)
  local it = iter(pkgdirs)
  assert(it, 'no.scan iter(pkgdirs) is nil')
  return function()
    if mod then for x in it do
    if type(x)=='string' then
      local rv=no.join(x, mod)
      rv=rv and rv:gsub('^%.%/','')
      rv=is.dir(rv) and rv or nil
      if rv then return rv end
      end end end end end

function no.searcher(mod, key)
  if type(mod)=='string' then return
    no.call(searchpath, sub(mod, key), pkgpath, sep)
    or no.call(searchpath, sub(mod, key), package.cpath, sep)
    or (no.parent(mod) and table.find({no.call(searchpath, sub(no.parent(mod), no.basename(mod), key), pkgpath, sep)}, is.file) or nil)
  end end

function no.files(items, tofull)
  local function subfiles(dir, full)
    if type(dir) == 'string' then
      dir=no.sub(dir)
      for it in paths.iterfiles(dir) do
        if full then
          coroutine.yield(no.join(dir, it))
        else
          coroutine.yield(it)
        end
      end
    end
    if type(dir)=='table' then dir=iter(dir) end
    if type(dir)=='function' then for it in dir do subfiles(it, full) end end
  end
  local getter = coroutine.wrap(subfiles)
  return function() return getter(items, tofull) end
  end

function no.dirs(items, torecursive)
  local function subdirs(dir, recursive)
    if type(dir) == 'string' then
      if recursive then
        coroutine.yield(dir)
        for subdir in paths.iterdirs(dir) do
          local to = no.join(dir, subdir)
          if recursive then subdirs(to, recursive) end
        end
      else
        for subdir in paths.iterdirs(dir) do
          coroutine.yield(subdir)
        end
      end
    end
    if type(dir)=='table' then dir=iter(dir) end
    if type(dir)=='function' then for it in dir do subdirs(it, recursive) end end
  end
  local getter = coroutine.wrap(subdirs)
  return function() return getter(items, torecursive) end
  end

function no.modules(items)
  local function submodules(mod)
    if type(mod) == 'string' then
      mod=no.sub(mod)
      local aseen = seen()
      for dir in no.scan(mod) do
        for it in paths.iterfiles(dir) do
          if it:match('%.lua$') and not it:match('%/?init.lua$') then
            it = no.strip(it)
            if not aseen[it] then coroutine.yield(it) end
          end
        end
        for it in paths.iterdirs(dir) do
--          if no.isfile(no.join(dir, it, 'init.lua')) then
            if not aseen[it] then coroutine.yield(it) end
--          end
        end
      end
    end
  end
  local getter = coroutine.wrap(submodules)
  return function() return getter(items) end
  end

function no.load(mod, key)
  if type(mod)=='string' then
  local path = mod:match('.lua$') and mod or cache.file(mod, key)
  if path then
    return loadfile(path)
  end end end

local _require
function no.require(o)
  local m, e
  if type(o)=='table' then error('no.require argument is table') end
  if type(o)~='string' or o=='' then return nil, 'no.require: arg #1 await string/meta.loader, got' .. type(o) end
  m = cache.loaded[o]
  if type(m)=='nil' or ((type(m)=='userdata' or type(m)=='number') and ((not cache.loaded[m]) or type(cache.loaded[m])~=type(m))) then
  if not log.protect then
    m,e = _require(o)
  else
    local path = no.searcher(o)
    if path then m,e = no.call(_require, o) end
  end
  end
  cache.loaded[o]=m
  return m, e
  end

pkgdirs = no.pkgdirs()

-- normalize for multi-arg cache key
sub = cache.sub/{normalize=no.sub, new=no.sub}
cache.conf.file={normalize=sub, new=no.searcher}
cache.conf.load={normalize=sub, new=no.require}

-- k is type name
-- v is object
cache.conf.instance={
  normalize=no.sub,
  put=function(self, k, v)
    if root[k] and is.toindex(v) then
      self[v]=no.sub(k)
  end end}

-- k is type name
-- v is object instance
cache.conf.type={
try=function(v) return v, v and getmetatable(v) end,
normalize=no.sub,
put=function(self, k, v)
  if root[k] and is.toindex(v) then
    local orig=k; k=no.sub(k)
    self[orig]=k
    self[k]=k
    self[v]=k
    if getmetatable(v) and not self[getmetatable(v)] then
      self[getmetatable(v)]=k
    end end end,}

-- cache.loaded[t.env]={}
-- k is type name
-- v is object
cache.conf.loaded={
  put=function(self, k, v)
    if is.toindex(v) and root[k] then
      self[no.sub(k)]=k
      k=no.sub(k)
      self[v]=v
      cache.instance[k]=v
      cache.type[k]=v
    end
  end,
  get=function(self, k)
    if type(k)~='string' then return rawget(self, k) end
    k=self[no.sub(k)]
    return package.loaded[k]
  end,}

if not has.value(no.load, package.searchers) then
  table.insert(package.searchers, 1, no.load) end

if require~=no.require then
  _require=require
  require=no.require
end

cache.loaded=package.loaded

return no