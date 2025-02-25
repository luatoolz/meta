require "compat53"
require "meta.table"
local mcache = require "meta.mcache"
local call = require "meta.call"
local paths = require "paths"
local is = require "meta.is"
local root = require "meta.mcache.root"
local has = {
  value = require 'meta.is.has.value',
}
local seen = require "meta.seen"
local iter = assert(require 'meta.iter', 'iter not loaded')
local no = {}

--local sep, msep, mdot = string.sep, string.msep, string.mdot
local sep = string.sep
require "meta.mcache.pkgdirs"

no.strip=string.stripper({'%/?init%.lua$', '%.lua$'})

no.unroot = require 'meta.module.unroot'
no.sub = require 'meta.module.sub'
no.searcher = require 'meta.module.searcher'

-- return module dirs for all pkg dirs
function no.scan(mod, orig)
  if type(mod)~='string' or #mod==0 then mod=nil end
  mod=no.sub(mod)
  local it = iter(mcache.pkgdirs)
  assert(it, 'no.scan iter(pkgdirs) is nil')
  return function()
    if mod then for x in it do
    if type(x)=='string' then
      local rv=sep:join(x, mod)
      rv=rv and rv:gsub('^%.%/','')
      rv=is.dir(rv) and rv or nil
      if rv then
        if orig then return x end
        return rv
    end end end end end end

mcache.conf.pkgdirz={
normalize=no.sub,
new=function(it)
  return table.map(no.scan(it)) end,}

mcache.conf.pkgdir={
normalize=no.sub,
get=function(self, k)
  if type(k)~='string' or #k==0 then return end
  if self[k]==false then return {} end
  if type(self[k])=='nil' then
    local rv=table.map(no.scan(k, true))
    self[k]=table()
    if rv and #rv>0 then
    for v in iter(rv) do
      local extlist = mcache.pkgdirs[v]
      extlist=extlist and (extlist % is.match.lua_dirext) or {}
      extlist=extlist[1]
      if extlist then
        local path = sep:join(v, k, extlist)
        if is.file(path) then
        table.append_unique(self[k], sep:join(v, k))
        end end end end
  if #self[k]==0 then self[k]=false end end
  return self[k] end,}

--[[
function no.searcher(mod, key)
  local searchpath, path, cpath = package.searchpath, package.path, package.cpath
  if type(mod)=='string' then
    local msub=no.sub(mod, key)
    if type(msub)=='string' then
      return call(searchpath, msub, path, sep)
          or call(searchpath, msub, cpath, sep)
--      or (no.parent(mod) and table.find({no.call(searchpath, no.sub(no.parent(mod), no.basename(mod), key), path, sep)}, is.file) or nil)
    end
  end end
--]]

function no.files(items, tofull)
  local function subfiles(dir, full)
    if type(dir) == 'string' then
      dir=no.sub(dir)
      for it in paths.iterfiles(dir) do
        if full then
          coroutine.yield(sep:join(dir, it))
        else
          coroutine.yield(it)
        end
      end
    end
    if type(dir)=='table' then dir=iter(dir) end
    if is.callable(dir) then for it in dir do subfiles(it, full) end end
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
          local to = sep:join(dir, subdir)
          if recursive then subdirs(to, recursive) end
        end
      else
        for subdir in paths.iterdirs(dir) do
          coroutine.yield(subdir)
        end
      end
    end
    if type(dir)=='table' then dir=iter(dir) end
    if is.callable(dir) then for it in dir do subdirs(it, recursive) end end
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
--          if no.isfile(sep:join(dir, it, 'init.lua')) then
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
  local m=no.sub(mod, key)
  local found=mcache.loaded[m] or mcache.loaded[mod]
  if found then return function() return found end end
  local path = mod:match('.lua$') and mod or mcache.file(m)
  if path then
    return loadfile(path)
--    local f=loadfile(path)
--    return function()
--      local data, e = f()
--      mcache.loaded[mod]=data
--      return data, e end
  end end end

local _require
function no.require(o)
  local m, e
  if type(o)=='table' then error('no.require argument is table') end
  if type(o)~='string' or o=='' then return nil, 'no.require: arg #1 await string/meta.loader, got' .. type(o) end
  m = mcache.loaded[o]
  if type(m)=='nil' or ((type(m)=='userdata' or type(m)=='number') and ((not mcache.loaded[m]) or type(mcache.loaded[m])~=type(m))) then
    m, e = call(_require, o)
  end
  mcache.loaded[o]=m
  return m, e
  end

-- normalize for multi-arg mcache key
--sub = mcache.sub/{normalize=no.sub, new=no.sub}
mcache.conf.file={normalize=no.sub, new=no.searcher}
mcache.conf.load={normalize=no.sub, new=no.require}

mcache.conf.files = {normalize=no.sub, new=function(it) return iter.map(no.files(no.scan(it)), no.strip) end}
mcache.conf.dirs  = {normalize=no.sub, new=function(it) return iter.map(no.dirs(no.scan(it))) end}
mcache.conf.modules={normalize=no.sub, new=function(it) return iter.map(no.modules(it)) end}

-- k is type name
-- v is object
mcache.conf.instance={
  normalize=no.sub,
  put=function(self, k, v)
    if root[k] and is.toindex(v) then
      if not self[v] then self[v]=no.sub(k) end
--      if not self[v] then self[v]=no.unroot(no.sub(k)) end
  end end}

-- k is type name
-- v is object instance
mcache.conf.type={
try=function(v) return v, v and getmetatable(v) end,
normalize=no.sub,
put=function(self, k, v)
  if root[k] and is.toindex(v) then
    local orig=k; k=no.sub(k)
    k=no.unroot(k)
    self[orig]=k
    self[k]=k
    self[v]=k
    if getmetatable(v) and not self[getmetatable(v)] then
      self[getmetatable(v)]=k
    end end end,}

-- k is type name
-- v is object instance
mcache.conf.fqmn={
try=function(v) return v, v and getmetatable(v) end,
normalize=no.sub,
put=function(self, k, v)
  if root[k] and is.toindex(v) then
    k=no.sub(k)
    self[v]=k
    if getmetatable(v) and not self[getmetatable(v)] then
      self[getmetatable(v)]=k
    end end end,}

-- mcache.object['mcache/root']='meta/mcache/root'
-- k is type name
-- v is object
mcache.conf.object={
put=function(self, k, v)
  k=no.sub(k)
  k=no.unroot(k)
  if not self[k] then self[k]=v end
  end,
get=function(self, k)
  return mcache.loaded[self[k]]
  end}

-- mcache.loaded[t.env]={}
-- k is type name
-- v is object
mcache.conf.loaded={
init=package.loaded,
put=function(self, k, v)
  if is.toindex(v) and root[k] then
    self[no.sub(k)]=k
    k=no.sub(k)
    self[v]=v
    mcache.instance[k]=v
    mcache.type[k]=v
    mcache.fqmn[k]=v
    mcache.object[k]=k
  end end,
get=function(self, k)
  if type(k)~='string' then
    return self[k]
  end
  return package.loaded[self[no.sub(k)]]
  end,}

if not has.value(no.load, package.searchers) then
  table.insert(package.searchers, 1, no.load) end

if require~=no.require then
  _require=require
  require=no.require
  end

return no