require "compat53"

local inspect = require "inspect"
local searcher = require "meta.searcher"
local path = require "meta.path"
local loaders = require "meta.loaders"
local sub = require "meta.sub"
local prequire = require "meta.prequire"
local dir = require "meta.dir"
local isdir = require "meta.isdir"
local preload = require "meta.preload"
local mt = require "meta.mt"
local mtindex = require "meta.mtindex"
local computed = require "meta.computed"
local noerror = require "meta.noerror"

local m = {}
mt(m).__call = function(self, origin) return setmetatable({origin=origin}, mt(self)) end
mt(m).__tostring = function(self) return self.name end
mt(m).__eq = function(self, o) return type(self)==type(o) and type(self)=='table' and self.name == o.name end

local rv={["nil"]=false, ["string"]=false}
local __computed = {
  name = sub,
  path = path,
  file = searcher,
  dir = function(self) return isdir(self.path, true) end,
  basename = function(self) local b = self.name:match("[^/]+$"); return (type(b)=='string' and #b>0) and b or nil end,
  isroot = function(self) return (not (self.name:match('%/'))) end,
  basedir = function(self) local b = self.name:gsub("%/?[^/]*$", '', 1); return b~='' and b or nil end,
  exists = function(self) return ((self.file) or (self.dir)) and true or false end,
--  error = function(self) return noerror[self] end,
  ok = function(self) if self.exists then return self end end,
  parent = function(self) if not self.isroot then return self(self.name:gsub("%/?[^/]*$", '', 1)) end end,
  subpath = function(self) return sub end,
  sub = function(self) return function(self, to)
--print('  sub', self.dir, self.subpath(self.dir, to))
    if type(to)=='string' and self.dir then return self(self.subpath(self.dir, to)) end
  end end,
  files = function(self)
    local rv = {}
    for it in paths.iterfiles(self.dir) do
      if it ~= 'init.lua' then
        table.insert(it:gsub('%.lua$', ''))
      end
    end
    return rv
  end,
  dirs = function(self)
    local rv = {}
    for it in paths.iterdirs(self.dir) do
      table.insert(it)
    end
    return rv
  end,
  load = function(self)
    local code = package.loaded[self.name] or package.loaded[self.origin]
    if code then
      return code
    end
    code, self.error = prequire(self.name, true)
    return code
  end,
  loaded = function(self)
    if rawget(self, 'load')~=nil and not rawget(self, 'error') then return true end
  end,
  loader = function(self) end,
--[[
  indexable
  iteratable
  callable
  isloader
--]]
}

return computed(m, __computed)
