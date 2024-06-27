require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"
local mt = require "meta.mt"
local is = require "meta.is"

local no = {}
no.roots = {}

local cache = require "meta.cache"
local sub, unsub, dir

local sep = _G.package.config:sub(1,1)
local dot = '.'
local msep = '%' .. sep
local mdot = '%' .. dot
local mmultisep = '%' .. sep .. '%' .. sep .. '+'

no.sep, no.dot, no.msep, no.mdot = sep, dot, msep, mdot
local searchpath, pkgpath, pkgloaded = package.searchpath, package.path, package.loaded

-- computable functions ---------------------------------------------------------------------------------------------------------------------

function no.object(self, key)
  assert(type(self)=='table')
  return (cache.loader[self] or {})[key] or no.computed(self, key)
  end

function no.computed(self, key)
  assert(type(self)=='table')
  return mt(self)[key]
    or (mt(self).__static or {})[key]
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

function no.callable(...)
  for i=1,select('#', ...) do
    local f=select(i, ...)
    if is.callable(f) then return f end end end
--    if type(f)=='function' or (type(f) == 'table' and type((getmetatable(f) or {}).__call) == 'function') then return f end end end

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

function no.mergevalues(...)
  local r, seen = {}, {}
  for _,t in ipairs({...}) do
    for k,v in ipairs(t) do
      if not seen[v] then
        table.insert(r, v)
        seen[v]=true
      end
    end
  end
  return r
  end

function no.mergekeys(...)
  if type(select(1, ...))=='table' and (select('#', ...)==1 or type(select(2, ...))=='nil') then return select(1, ...) end
  local r, seen = {}, {}
  for _,t in ipairs({...}) do
    for k,v in pairs(t) do
      if not seen[k] then
        table.insert(r, v)
        seen[k]=true
      end
    end
  end
  return r
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
    if not f and no.callable(arg[i]) then f=arg[i] end
    if type(arg[i])=='string' then msg[#msg+1]=arg[i] end
  end
  local assertion = "assertion." .. name
  local ist = f
  _ = ist or error('error no.asserts(' .. name .. ')')
  local test = function(state, arguments)
    return no.assert(ist(table.unpack(arguments, 1, n or (table.maxn and table.maxn(arguments) or nil) or #arguments)))
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
  if no.callable(f) then
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
  return tovalue and f or ((type(en)=='number' and en~=2^63 and cl) and true or false)
  end

local function fmtlua(x) return string.format('%s.lua', x) end
function no.ismodule(...)
--  local tovalue
  local len = select('#', ...)
  if len==0 then return nil end
  if type(select(len, ...))=='boolean' then
--    tovalue=select(len, ...)
    len=len-1
    if len==0 then return nil end
  end
  if table.any({...}, '') then return false end
  assert(not table.any({...}, ''), 'got empty lines')
  local p = no.join(...)
  return table(p, no.join(p, 'init')):map(fmtlua):filter(no.isfile):first()
  end

-- if key: return basedir(m)/key
-- if key==nil: basedir(m)
function no.dir(m, key)
  if type(m)=='string' then return
    no.isdir(no.strip(cache.file(m, key)), true)
    or no.isdir(sub(no.strip(no.searcher(m)), key), true)
    or no.isdir(sub(sub(dir(no.parent(m)), no.basename(m)), key), true)
    or no.isdir(no.tryfromloaded(m, key), true)
  end end

function no.tryfromloaded(m, key)
  m=sub(m, key)
  local searchm, found
  for k,v in pairs(package.loaded) do
    if type(k)=='string' then
      searchm=nil
      if k:startswith(m) then searchm=k end
      if k:startswith(no.sub(m)) then searchm=no.sub(k) end
      if searchm then
        if not found or #found>#searchm then found=searchm end
      end
    end
  end
  if found then
    local d=dir(found)
    while m~=found and #found>#m do
      found=no.parent(found)
      d=no.parent(d)
      if no.isdir(d) then cache.dir[found]=d end
    end
  end
  return found
end

-- loader functions ---------------------------------------------------------------------------------------------------------------------

function no.searcher(mod, key)
  if type(mod)=='string' then return
    no.call(searchpath, sub(mod, key), pkgpath, sep) or
    (no.parent(mod) and no.isfile(no.call(searchpath, sub(no.parent(mod), no.basename(mod), key), pkgpath, sep), true) or nil)
  end end

function no.loaded(mod, key)
  if mod then
    local loaded = package.loaded
    return  loaded[(not key) and mod or nil] or
            loaded[unsub(mod, key)] or
            loaded[sub(mod, key)]
  end end

function no.load(mod, key)
  if type(mod)=='string' then
  local path = mod:match('.lua$') and mod or cache.file(mod, key)
  if path then
    return assert(loadfile(path))
  end end end

local orequire
function no.require(...)
  local err = {}
  local o, m, e
  for i=1,select('#', ...) do
    o=select(i, ...)
    if type(o)=='table' then return o end
    if type(o)~='string' or o=='' then return nil, 'no.require arg #1 should be string or meta.loader, got' .. type(o) end
    m, e = no.call(orequire, o)
    if m and not e then
--      cache.loaded[o]=m
--      cache.loaded[sub(o)]=m
      return no.cache(o, m)
    end
    if e then table.insert(err, e) end
  end
  return m, table.concat(err, "\n-----------------------------\n")
  end

local indextypes={['function']=true, ['table']=true, ['userdata']=true, ['CFunction']=true}

function no.cache(k, v)
  assert(type(k)=='string', 'no.cache await string, got' .. type(k))
  cache.loaded(v, k)
  if type(k)=='string' and k~='' and no.roots[no.root(k)] and indextypes[type(v)] then
    cache.object(v, k)
    cache.typename(sub(k), k, v) --, type(v)=='table' and mt(v) or nil)
    if type(v)=='table' and getmetatable(v) then
      cache.mt(getmetatable(v), k, v)
      cache.typename[mt(v)]=sub(k)
    end
  end
  return v
  end

function no.parse(...)
  no.track(...)
  local c = package.loaded
  for k,v in pairs(c) do no.cache(k, v) end end

function no.track(...)
  for _,v in pairs({...}) do v=no.root(v)
  if v then no.roots[v]=true end end end

no.track('meta')

-- normalize is a must for multi-arg cache key
sub = cache('sub', no.sub, no.sub)
unsub = cache('unsub', sub, no.unsub)
cache('file', sub, no.searcher)
dir = cache('dir', sub, no.dir)

cache('load', sub, no.require)
cache('loaded', sub, no.loaded)

cache('typename', sub)
cache('mt', sub)
cache('object', sub)

if not no.hasvalue(package.searchers, no.load) then
  table.insert(package.searchers, 1, no.load) end

if require~=no.require then
  orequire=require
  require=no.require
end

no.parse()

return no
