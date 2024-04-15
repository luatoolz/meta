require "compat53"

cache_dir = {}

local match = '%'
local dir_separator = _G.package.config:sub(1,1)
local match_dir_separator = match .. dir_separator
local dot = '.'
local match_dot = match .. dot

local function searcher(module_name)
  local _, mn = debug.getlocal(1, 1)
  module_name = module_name or mn
  assert(type(module_name)=='string' and #module_name>0)
  local p, err = package.searchpath(module_name, package.path, dir_separator)
  if p then
    return assert(loadfile(p))
  end
  return err
end
table.insert(package.searchers, searcher)

local class = {}
local mt = { __index=class }

class.dir_separator = dir_separator

local function submodule(m, key)
  local kdots = (key or ''):match(match_dot)
  local mdots = m:match(match_dot)
  local mslash = m:match(match_dir_separator)
  local sep = dir_separator
  if not (mdots and mslash) then
    m = m:gsub(match_dot, dir_separator)
  end
  return key and table.concat({m, key}, sep) or m
end

function class.prequire(m)
  local ok, rv = pcall(require, m) 
  if not ok then
    return nil, rv
  end
  if rv==true then return nil end
  return rv
end

function class.isdir(dir)
  if dir==nil then return nil end
  local rv = io.open(dir, "r")
  if rv==nil then return nil end
  local pos = rv:read("*n")
  local it = rv:read(1)
  local set0 = rv:seek("set", 0)
  local en = rv:seek("end")
  local cl = rv:close()
  return pos==nil and it==nil and en~=0 and cl
end

function class.path(m, key)
  assert(type(m)=='string' and #m>0)
  if cache_dir[submodule(m, key)] then return cache_dir[submodule(m, key)] end
  local dir, err
  if cache_dir[submodule(m)] then
    dir=cache_dir[submodule(m)]
  end
  if not dir then dir, err = package.searchpath(submodule(m), package.path, class.dir_separator) end
  if dir and not err then
    if dir:match('%/init%.lua$') then dir = dir:gsub('%/init%.lua$', '') end
    if class.isdir(dir) and not cache_dir[submodule(m)] then cache_dir[submodule(m)]=dir end
    if key then dir = dir .. class.dir_separator .. key end
    if class.isdir(dir) then
      cache_dir[submodule(m, key)]=dir
      return dir
    end
  end
  if not key and m:match('%/') then
    local subm = submodule(m)
    local kk = subm:match("[^/]+$")
    local mm = subm:gsub("%/[^/]+$", '')
    if mm .. class.dir_separator .. kk == m then
      return class.path(mm, kk)
    end
  end
end

function class.preload(m, o)
  local mpath = class.path(m)
  assert(class.isdir(mpath))
  for it in paths.iterfiles(mpath) do
    if it ~= 'init.lua' then
      _ = o[it:gsub('%.lua$', '')]
    end
  end
  for it in paths.iterdirs(mpath) do
    _ = o[it]
  end
  return o
end

function class:new(m, preload, recursive)
  assert(type(m)=='string' and #m>0)
  local mpath = class.path(m)
  assert(class.isdir(mpath))
  local o = setmetatable({}, {
    __index = function(table, key)
      local sub = submodule(m, key)
      local loaded, err = class.prequire(sub)
      if not loaded and (err~=nil and err~=true) then
        loaded, err = class(sub, recursive and preload or false, recursive)
      end
      if not loaded then
        error(err)
      end
      return loaded and rawget(rawset(table, key, loaded), key) or nil
    end
  })
  return preload and class.preload(m, o) or o
end
mt.__call = class.new

return setmetatable(class, mt)
