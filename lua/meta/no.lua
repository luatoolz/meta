require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"
local cache = require "meta.cache"
local paths = require "paths"
local is = require "meta.is"
local mt = require "meta.mt"
local seen = require "meta.seen"
local iter = table.iter
local roots = cache.ordered.roots + 'meta'
local toindex = cache.toindex
local no = {}

local sub, unsub

local sep, dot, msep, mdot, mmultisep = string.sep, string.dot, string.msep, string.mdot, string.mmultisep
local searchpath, pkgpath, pkgloaded = package.searchpath, package.path, package.loaded
local pkgdirs

-- computable functions ---------------------------------------------------------------------------------------------------------------------
function no.object(self, key)
  assert(type(self)=='table')
  return no.call(mt(self).__preindex, self, key)
    or no.computed(self, key)
    or (cache.loader[self] or cache.loader[getmetatable(self)] or {})[key]
    or no.call(mt(self).__postindex, self, key)
  end

function no.computed(self, key)
  assert(type(self)=='table')
  return mt(self)[key]
    or no.computable(self, mt(self).__computable, key)
    or no.save(self, key, no.computable(self, mt(self).__computed, key))
  end

function no.computable(self, t, key)
  if type(t)=='nil' or (type(t)=='table' and not next(t)) or type(key)=='nil' then return nil end
  assert((type(key)=='string' and #key > 0) or type(key) == 'number', 'no.computable: want key string/number, got ' .. type(key))
  assert(type(t)=='table', 'no.computable: want table, got ' .. type(t))
  return no.call(rawget(t, key), self)
  end

-- helper functions ---------------------------------------------------------------------------------------------------------------------

no.hasvalue=table.any or function(self, v)
  if type(self)=='table' then
    if #self>0 then
      for i=1,#self do if self[i]==v then return true end end
    elseif next(self) then
      for _,it in pairs(self) do if it==v then return true end end
    end
  end
  return false
  end

function no.join(...)
  local rv = table.concat(table.filter({...}, function(x) return type(x)=='string' end), sep)
  return (rv and rv~='') and string.gsub(rv, mmultisep, sep) or nil
  end

function no.save(self, k, ...)
  local v = ...
  if type(self)=='nil' or type(k)=='nil' or type(v)=='nil' then return nil end
  assert(type(self)=='table', 'no.save: want table, but got ' .. type(self))
  rawset(self, k, v)
  return ...
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

function no.root(x) return no.strip(x, '[./].*$') end

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

function no.unsub(mod, ...)
  if type(mod)=='table' then return mod end
  if type(mod)=='string' then
  mod=no.to(dot, mod)
  for i=1,select('#', ...) do
    mod=no.to(dot, mod, select(i, ...))
  end
  if mod~='' then return mod end
  end end

-- asserts/call ---------------------------------------------------------------------------------------------------------------------
function no.asserts(name, ...)
  local assert = require "luassert"
  local say    = require "say"
  local arg = {...}
  local n, f, msg = nil, nil, {}
  for i=1,select('#', ...) do
    if type(arg[i])=='number' then n=arg[i] end
    if not f and is.callable(arg[i]) then f=arg[i] end
    if type(arg[i])=='string' then msg[#msg+1]=arg[i] end
  end
  local assertion = "assertion." .. name
  local ist = f
  _ = ist or error('error no.asserts(' .. name .. ')')
  local test = function(state, arguments)
    local len = math.max(n or 0, table.maxi(arguments) or 0)
    if len>0 then return no.assert(ist(table.unpack(arguments, 1, len))) end
    return no.assert(ist(table.unpack(arguments)))
  end
  if #msg>0 then say:set(assertion .. ".positive", msg[1]) end
  if #msg>1 then say:set(assertion .. ".negative", msg[2]) end

  assert:register("assertion", name, test,
                  assertion .. ".positive",
                  assertion .. ".negative")
  return test
  end

function no.assert(x, ...) return x end

-- pcall function with m or self as argument: f(m) or f(self)
-- return result or nil + save error
function no.call(f, ...)
  local ok
  if is.callable(f) then
    local res = table.pack(pcall(f, ...))
    ok = res[1]
    if not ok then return nil, res[2] end
    return table.unpack(res, 2)
    end end

-- fs/path functions ---------------------------------------------------------------------------------------------------------------------

function no.isdir(d, tovalue)
  if d==nil then return nil end
  assert(type(d)=='string')
  if d=='' then d='.' end
  local rv = io.open(d, "r")
  if rv==nil then return nil end
  local pos = rv:read("*n")
  local it = rv:read(1)
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return tovalue and d or ((pos==nil and it==nil and en~=0 and cl) and true or false)
  end

function no.isfile(f, tovalue)
  if f==nil or f=='' or f=='.' then return nil end
  assert(type(f)=='string')
  local rv = io.open(f, "r")
  if rv==nil then return nil end
  rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return tovalue and f or ((type(en)=='number' and en~=math.maxinteger and en~=2^63 and cl) and true or false)
  end

local function fmtlua(x) return string.format('%s.lua', x) end
function no.ismodule(...)
  local len = select('#', ...)
  if len==0 then return nil end
  if type(select(len, ...))=='boolean' then
    len=len-1
    if len==0 then return nil end
  end
  if table.any({...}, '') then return false end
  assert(not table.any({...}, ''), 'got empty lines')
  local p = no.join(...)
  return table(table(table(p, no.join(p, 'init')):map(fmtlua)):filter(no.isfile)):first()
  end

-- loader functions ---------------------------------------------------------------------------------------------------------------------

function no.pkgdirs()
  return cache.ordered.pkgdirs .. ((table() .. (package.path:gsub('(' .. msep .. '?%?[^;]+)', ''):gmatch("([^;]+)"))) % no.isdir)
  end

-- return module dirs for all pkg dirs
function no.scan(mod)
  if type(mod)~='string' or #mod==0 then mod=nil end
  mod=no.sub(mod)
  local it = iter(pkgdirs)
  assert(it, 'no.scan iter(pkgdirs) is nil')
  return function()
    if not mod then return nil end
    local rv
    for x in it do
      if type(x)=='string' then
        rv=no.join(x, mod) or ''
        rv=no.isdir(rv:gsub('^%.%/',''), true)
        if rv then return rv end
      end
    end
    return nil
  end end

function no.searcher(mod, key)
  if type(mod)=='string' then return
    no.call(searchpath, sub(mod, key), pkgpath, sep) or
    (no.parent(mod) and no.isfile(no.call(searchpath, sub(no.parent(mod), no.basename(mod), key), pkgpath, sep), true) or nil)
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
    if type(dir) == 'table' then
      local mtd = (getmetatable(dir or {}) or {})
      local __iter = mtd.__iter
      if __iter then
        dir = __iter(dir)
      elseif mtd.__pairs then
        local _pairs = mtd.__pairs
        for _, it in _pairs(dir) do subfiles(it, full) end
        return
      elseif mtd.__ipairs then
        local _pairs = mtd.__ipairs
        for _, it in _pairs(dir) do subfiles(it, full) end
        return
      elseif dir[1] then
        for _, it in ipairs(dir) do subfiles(it, full) end
        return
      else
        for _, it in pairs(dir) do subfiles(it, full) end
        return
      end
    end
    if type(dir) == 'function' then for it in dir do subfiles(it, full) end end
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
    if type(dir) == 'table' then
      local mtd = (getmetatable(dir or {}) or {})
      local __iter = mtd.__iter
      if __iter then
        dir = __iter(dir)
      elseif mtd.__pairs then
        local _pairs = mtd.__pairs
        for _, it in _pairs(dir) do subdirs(it, recursive) end
        return
      elseif mtd.__ipairs then
        local _pairs = mtd.__ipairs
        for _, it in _pairs(dir) do subdirs(it, recursive) end
        return
      elseif dir[1] then
        for _, it in ipairs(dir) do subdirs(it, recursive) end
        return
      else
        for _, it in pairs(dir) do subdirs(it, recursive) end
        return
      end
    end
    if type(dir) == 'function' then for it in dir do subdirs(it, recursive) end end
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

function no.loaded(mod, key)
  if mod then
    local loaded = pkgloaded
    return  loaded[(not key) and mod or nil] or
            loaded[unsub(mod, key)] or
            loaded[sub(mod, key)]
  end end

function no.load(mod, key)
  if type(mod)=='string' then
  local path = mod:match('.lua$') and mod or cache.file(mod, key)
  if path then
    return loadfile(path)
  end end end

local _require
function no.require(o)
  local m, e
--  local err = {}
--  local o, m, e
--  for i=1,select('#', ...) do
--    o=select(i, ...)
    if type(o)=='table' then error('no.require argument is table') end
--assert(false, 'no.require argument is table'); return o end
    if type(o)~='string' or o=='' then return nil, 'no.require: arg #1 await string/meta.loader, got' .. type(o) end
--    e=cache.loaderr[o] or cache.loaderr[sub(o)]
--    if e then return nil,e end
    m=no.loaded(o)
    if type(m)=='nil' then m,e=no.call(_require, o); return no.cache(o, m, e) end
    if m and not cache.loaded[m] or type(cache.loaded[m])~=type(m) or type(e)~='nil' then no.cache(o, m, e) end

--    if e then
--      cache.loaderr(e, o, sub(o))
--      table.insert(err, e)
--    else
--      if m then
--        cache.loaderr[o]=nil;
--        return m
--      end
--    end

--  end
  if e then return m, e end
  return m
--table.concat(err, "\n")
  end

function no.cache(k, v, e)
  assert(type(k)=='string', 'no.cache await string, got' .. type(k))
  if e then
--    cache.loaderr(e, k, sub(k))
    return nil, e
  end
    cache.loaded(v, k, sub(k))
    if type(k)=='string' and k~='' and roots[no.root(k)] and toindex[type(v)] then
      cache.instance(v, k, sub(k))
      cache.type(sub(k), k, v)
      if type(v)=='table' and getmetatable(v) then
        if not cache.mt[getmetatable(v)] then cache.mt(getmetatable(v), k, sub(k), v) end
        if not cache.type[getmetatable(v)] then cache.type[getmetatable(v)]=sub(k) end
      end
    end
  return v
  end

function no.track(...) return roots .. {...} end
function no.parse(...) no.track(...); for k,v in pairs(pkgloaded) do no.cache(k, v) end end

pkgdirs = no.pkgdirs()

-- normalize is a must for multi-arg cache key
sub = cache('sub', no.sub, no.sub)
unsub = cache('unsub', sub, no.unsub)
cache('file', sub, no.searcher)

cache('load', no.sub, no.require)
cache('loaded', no.sub, no.loaded)
--cache('loaderr', no.sub)

cache('type', no.sub)
cache('mt', no.sub)
cache('instance', no.sub)

if not no.hasvalue(package.searchers, no.load) then
  table.insert(package.searchers, 1, no.load) end

if require~=no.require then
  _require=require
  require=no.require
end

no.parse()

return no
