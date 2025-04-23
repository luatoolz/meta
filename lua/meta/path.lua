require 'meta.table'
local co = require 'meta.call'
local iter = require 'meta.iter'
local checker = require 'meta.checker'
local selector = require 'meta.select'
local lfs = require 'lfs'
local dir, file

local computed, setcomputed =
  require "meta.mt.computed",
  require "meta.mt.setcomputed"

local this = {}
local sep  = string.sep
--assert(sep == '/', 'got ' .. type(sep) .. ' ' .. tostring(sep))
--local join = sep:joiner()

local special = {
  socket = true,
  ["named pipe"] = true,
  ["char device"] = true,
  ["block device"] = true,
  ["other"] = true,
}

local has_tostring = function(x) return type((getmetatable(x) or {}).__tostring)~='nil' or nil end
local is = {
  string   = function(s) return type(s)=='string' or nil end,
  stringer = checker({table=has_tostring, userdata=has_tostring, number=true, boolean=true}, type),
  this     = function(x) return rawequal(getmetatable(this), getmetatable(x)) end,
  plain    = function(x) return type(x)=='string' and not x:match('%s%s' ^ {'%', sep}) end,
  callable = require 'meta.is.callable',
  file     = assert(require 'meta.is.file'),
  dir      = assert(require 'meta.is.dir'),
  path     = assert(require 'meta.is.path'),
}
local stringer = function(x) return is.stringer(x) and tostring(x) or x end
local splitter = function(it)
  local x = stringer(it)
  if type(x)=='function' then return x end
  if x=='' or x=='/' then x={x} end
  if type(x)=='table' and #x>0 then return iter(x) end
  if type(x)=='string' then
    if x:match('^/+') then return iter({'/', x:gmatch('[^/]+')}) end
    return x:gmatch('[^/]+')
  end
--  return x and iter(x) or function() return nil end
  return function() return nil end
end
local fn = {
  null = function() end,
  noop = function(...) return ... end,
}

return setmetatable(this, {
__computed  = {
  cwd       = function(self) return (not self.isabs) and lfs.currentdir() end,
},
__computable = {
  attr      = function(self) return lfs.symlinkattributes(self.path) or lfs.attributes(self.path) or {} end,
  target    = function(self) return self.islink and this(self.base, self.attr.target) end,
  mode      = function(self) return self.attr.mode end,

  name      = function(self) return self[-1] end,
  basedir   = function(self) return string.join('/',self(self[{1,-2}])) end,
  base      = function(self) return self(self[{1,-2}]) end,

  path      = function(self) return tostring(self) end,
  ext       = function(self) return self.path:match('%.([^%.]*)$') end,
  exists    = function(self) return self.mode and true or nil end,
  notexists = function(self) return (not self.mode) and true or nil end,

-- linux/win both possible
  root      = function(self) return self[1] and self[1]:match('^[%/%\\]+') end,

-- linux/win both possible in some network tools; \Device\HarddiskVolume2, d:\, d:/, \\srv\x, //srv/x, "\\srv\with space"\
  drive     = function(self) return self[1] and self[1]:match('^(%a)%:[%/%\\]?') end,
  netunc    = function(self) return self[1] and self[1]:match('^%"?([%/%\\][%/%\\][^%/%\\]+[%/%\\][^%"%/%\\]+)[%/%\\]*%"?') end,

-- windows only, \\?\, \\?\Volume{...}\, etc
  sysunc    = function(self) return self[1] and self[1]:match('^(%\\%\\?%??%\\?[^%\\]+)%\\?') end,

-- any unc does apply
  isabs     = function(self) return (self.root or self.drive) and true or nil end,
  abs       = function(self) return self.isabs and self or self(self.cwd, self) end,

  isdir     = function(self) return self.mode=='directory' or nil end,
  nondir    = function(self) local m=self.mode; return m and m~='directory' or nil end,
  isfile    = function(self) return self.mode=='file' or nil end,
  islink    = function(self) return self.mode=='link' or nil end,
  isspecial = function(self) return special[self.mode] or nil end,

  obj_dir   = function(self) return self.isdir and select(2, lfs.dir(self.path)) end,
  anydir    = function(self) if self.isdir then
    local it, rd = lfs.dir(self.path)
    for rv in it,rd do
      if rv~='.' and rv~='..' and (self/rv).isdir then rd:close(); return rv end
    end
  end end,

  items     = function(self) local pred = function(n) if (n and n~='.' and n~='..') then return n end end
    return self.isdir and co.wrap(function() for n in lfs.dir(self.path) do co.yieldok(pred(n)) end end) or fn.null end,

  fileitems = function(self) return self.files * selector.name end,
  diritems  = function(self) return self.dirs  * selector.name end,

  dirs      = function(self) return iter(self.ls) % is.dir end,
  files     = function(self) return iter(self.ls) % is.file end,

  ls        = function(self) return iter(co.wrap(function() for it in self.items do co.yield(self/it) end end)) end,
  lsr       = function(self) return co.wrap(function() for it in self.items do local p = self/it; co.yield(p);
                                    if p.isdir then for el in p.lsr do co.yield(el) end end end end) end,

  filetree  = function(self) return self.isdir and co.pool(self.dirtree,
                function(prod) for d in prod do for f in d.files do co.yieldok(this(f)) end end end
              ) or fn.null end,

  dirtree   = function(self) return self.isdir and co.wrap(function()
    co.yieldok(self)
    for it in self.dirs do
      for el in it.dirtree do co.yieldok(self(el)) end end end) or fn.null end,

  mkdir     = function(self) return self.isdir or lfs.mkdir(self.path) end,
  rmdir     = function(self)
    if not self.exists then return true end
    if self.isdir then return assert(lfs.rmdir(self.path)) end
--      local r,e = lfs.rmdir(self.path)
--      if e and not r then error(e) end
--      return r
--    end
    return self.notexists
--    return (not self.exists) or (self.isdir and lfs.rmdir(self.path)) or nil
  end,

  mkdirp    = function(self) local ex, tail, ok, e = self.abs, {}
    while (not ex.isdir) and #ex>1 do table.insert(tail, table.remove(ex)) end
    repeat table.insert(ex, table.remove(tail))
           if not ex.isdir then ok, e=lfs.mkdir(ex.path) end
    until #tail<=0 or e
    return ok, e
  end,

  rmfiles   = function(self) return self.isdir and iter.each(self.files, selector.rm) or true end,
  rmfilesr  = function(self) return self.isdir and iter.each(self.filetree, selector.rm) or true end,

  rmdirsr   = function(self)
    if self.isdir then
      iter.each(self.filetree, selector.rm)
      local cur, d = self.clone
      while self.isdir and #cur>=#self do
        repeat d=cur.anydir; if d then table.insert(cur, d) end; until not d
        _=cur.rmfiles
        if not cur.rmdir then return error('unable rmdir' ^ cur)
        else if #cur>#self then table.remove(cur) end end
      end
      return self.rmdir
    end
    return (not self.exists) and true or nil
  end,

  rmall     = function(self) return self.rm or self.rmdirsr end,
  rm        = function(self) return (not self.exists) or ((not self.isdir) and os.remove(self.path)) or nil end,

-- file items
  reader    = function(self) return self:open('rb') end,
  writer    = function(self) return self:open('w+b') end,
  appender  = function(self) return self:open('a+b') end,

  numitems  = function(self) local n=0; return self.isdir and iter.reduce(self.items, function() n=(n or 0)+1; return n end) end,
  numfiles  = function(self) local n=0; return self.isdir and iter.reduce(self.files, function() n=(n or 0)+1; return n end) end,
  numdirs  = function(self) local n=0; return self.isdir and iter.reduce(self.dirs, function() n=(n or 0)+1; return n end) end,

  size      = function(self) return self.isfile and self.attr.size end,
  content   = function(self) local r=self.reader; if r then return r:read('*a'), r:close() end end,

-- typed
  clone     = function(self) return setmetatable(({}), getmetatable(self)) .. self end,
  instance  = function(self) return self.isfile and self.file or (self.isdir and self.dir) or self end,

  file      = function(self)
    file = file or package.loaded['meta.file'] or co(require,'meta.file')
    return file(self.clone) end,
  dir       = function(self)
    dir = dir or package.loaded['meta.dir'] or co(require,'meta.dir')
    local rv = dir(self.clone)
    return rv
end,
},
__add = function(self, v)
  if type(v)=='nil' then return self end
  if not (is.plain(v) or v==sep) then return self .. v end
  if v=='.' or v=='' then return self end
  if v=='..' and #self>0 and self[#self]~='..' then
    table.remove(self)
    return self
  end
  if (v==sep) then
    if #self>0 then v=nil end
  end
  if is.string(v) and v~=sep and v:match('%a%:[%/%\\]?') and #self>0 then v=nil end
  if is.string(v) then table.insert(self, v) end
  return self
end,
__call = function(self, x, ...)
  if is.this(x) then return x .. {...} end
  return (setmetatable({}, getmetatable(self)) .. x) .. {...}
end,
__concat = function(self, it)
  if it then for v in splitter(it) do table.append(self, v) end end
  return self
end,
__div = function(self, it)
  if type(it)=='nil' then return self end
  return (self() .. self) .. it
end,
__eq = function(a, b)
  return (type(a)==type(b) and rawequal(getmetatable(a),getmetatable(b))) and tostring(a)==tostring(b)
end,
__export = function(self) return tostring(self.abs) end,
__id = tostring,
__name = 'path',
--__iter = function(self, to) return self.isdir and iter(self.items, to) end,
--__mod = iter.filter,
--__mul = iter.map,
--[[
__mod = function(self, it)
  if type(self)=='table' and rawequal(getmetatable(self),getmetatable(this)) then
    if type(it)=='string' then it=string.matcher(it) end
    return self.isdir and iter.filter(self.items, it) or {}
  end
end,
__mul = function(self, it)
  if type(it)=='string' then it=string.matcher(it) end
  return self.isdir and iter.map(self.items, it) or {}
end,
--]]
__index = computed,
__newindex = setcomputed,
__sub = function(self, it)
  if type(it)=='number' then
    while it>0 and #self>0 do
      table.remove(self)
      it=it-1
    end
    return self
  end
  if is.plain(it) then
    if #self>0 and self[#self]==it then table.remove(self) end
    return self
  end
  local tail = self(it)
  if is.this(tail) then
    if self==tail or (table.concat(self, sep, (#self+1)-#tail, #self)==table.concat(tail, sep)) then
      for i=1,#tail do table.remove(self) end
    end
  end
  return self
end,
__tostring = function(self)
  local s = (getmetatable(self) or {}).__sep or sep
  local ts = table.concat(self, s):gsub('^/+','/')

--  print('tostring(path)==', s, ts)
  return ts
--  return table.concat(self, sep):gsub('^/+','/')
end,
})