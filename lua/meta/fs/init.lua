require 'meta.table'
local co = require 'meta.call'
local iter = require 'meta.iter'
--local checker = require 'meta.checker'
local selector = require 'meta.select'
--local save = require 'meta.table.save'
local lfs = require 'lfs'

local meta = require 'meta.lazy'
local is, fn, pkg = meta({'is', 'fn', 'fs'})
_ = is .. 'fs'
local _ = fn[{'n','null', 'mt','args','swap'}]
local alias = pkg.type
local match={mode=string.matcher('^[rwa]+?b?$')}
_=match

--[[
table.select(fs, {'cwd','attr','target','type','exists','isfile','islink','ispipe','isdir','inode','age','size','rm'})
--]]

local path
local fs
fs = setmetatable({
-- path/common
  cwd       = function(self) return lfs.currentdir() end,
  lattr     = function(self) return self and lfs.symlinkattributes(tostring(self)) or {} end,
  attr      = function(self) return self and lfs.attributes(tostring(self)) or {} end,
  type      = function(self) return alias[fs.attr(self).mode] end,
  exists    = function(self) return (fs.islink(self) or fs.attr(self).mode) and true or nil end,
  target    = function(self) local attr=fs.lattr(self)
    return alias[attr.mode]=='link' and pkg.path(self[{0,-2}], attr.target) end,
  rpath     = function(self) return tostring(fs.target(self) or self) end,

  inode     = function(self) return fs.attr(self).ino end,
  age       = function(self) return os.time() - fs.attr(self).modification end,

  badlink   = function(self) return (fs.islink(self) and not fs.type(self)) and true or nil end,
  islink    = function(self) return alias[fs.lattr(self).mode]=='link' or nil end,
  ispipe    = function(self) return fs.type(self)=='pipe' or nil end,
  isfile    = function(self) return fs.type(self)=='file' or nil end,
  isdir     = function(self) return fs.type(self)=='dir' or nil end,
--  nondir    = function(self) return fs.type(self) and fs.type(self)~='dir' or nil end,
--    isspecial = function(self) return special[self.attr.mode] or nil end,

  isabs     = function(self) return self[0] and true or nil end,
  abs       = function(self) return self.isabs and self or (self()..self.cwd)+self[{1}] end,

-- file
  size      = function(self) local attr=fs.attr(self); return alias[attr.mode]=='file' and attr.size end,
  rm        = function(self) return (not fs.exists(self)) or ((not fs.isdir(self)) and os.remove(tostring(self))) or nil end,

--[[
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
--]]
-------------------------------------------------------------------------------------------------

--[[
  finder    = function(self) return (not fs.isdir(self)) and fn.null or function(pred)
    local it, rd, n, found = lfs.dir(fs.rpath(self))
    repeat n=rd:next()
    until n==nil or pred(n)
    rd:close()
    return n
  end end end,
--]]
  lz        = function(self) return (not fs.isdir(self)) and fn.null or
    iter(co.wrap(function() for n in lfs.dir(fs.rpath(self)) do co.yieldok(n) end end))%is.fs.name*table.caller(path)*tostring end,

  obj_dir   = function(self) return self.isdir and select(2, lfs.dir(tostring(self))) end,
  anydir    = function(self) if self.isdir then
    local it, rd = lfs.dir(tostring(self))
    for rv in it,rd do
      if rv~='.' and rv~='..' and (self..rv).isdir then rd:close(); return rv end
    end
  end end,

  items     = function(self) path=path or pkg.path
    local pred = function(n) if (n and n~='.' and n~='..') then return n end end
    return path(self).isdir and co.wrap(function() for n in lfs.dir(tostring(self)) do co.yieldok(pred(n)) end end) or fn.null end,

  fileitems = function(self) return self.files * selector.name end,
  diritems  = function(self) return self.dirs  * selector.name end,
  dirs      = function(self) return iter(self.ls) % is.fs.dir end,
  files     = function(self) return iter(self.ls) % is.fs.file end,

  ls        = function(self) path=path or pkg.path; return iter(co.wrap(function() for it in fs.items(self) do co.yield(path(self, it)) end end)) end,
  lsr       = function(self) return co.wrap(function() for it in self.items do local p = self..it; co.yield(p);
                                    if p.isdir then for el in p.lsr do co.yield(el) end end end end) end,

------------------------------------------------------------------------------------------------------------------------------------
  filetree  = function(self) return self.isdir and co.pool(self.dirtree,
                function(prod) for d in prod do for f in d.files do co.yieldok(self(f)) end end end
              ) or fn.null end,

  dirtree   = function(self) return self.isdir and co.wrap(function()
    co.yieldok(self)
    for it in self.dirs do
      for el in it.dirtree do co.yieldok(self(el)) end end end) or fn.null end,
------------------------------------------------------------------------------------------------------------------------------------

  mkdir     = function(self) return fs.isdir(self) or lfs.mkdir(fs.rpath(self)) end,
  rmdir     = function(self) return (not fs.exists(self)) or (fs.isdir(self) and lfs.rmdir(fs.rpath(self))) or nil end,
  mkdirp    = function(self) local ex, tail, ok, e = fs.isdir('.') and (self..'') or self.abs, {}
    while (not ex.isdir) and #ex>1 do table.insert(tail, table.remove(ex)) end
    repeat table.insert(ex, table.remove(tail))
           if not ex.isdir then ok, e=lfs.mkdir(tostring(ex)) end
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
  numitems  = function(self) local n=0; return self.isdir and iter.reduce(self.items, function() n=(n or 0)+1; return n end) end,
  numfiles  = function(self) local n=0; return self.isdir and iter.reduce(self.files, function() n=(n or 0)+1; return n end) end,
  numdirs  = function(self) local n=0; return self.isdir and iter.reduce(self.dirs, function() n=(n or 0)+1; return n end) end,
},{
__concat=function(a,b)
  iter.collect(iter(b), a)
  return a
end,
__index=function(self, k)
  return table.select(self, k) or pkg[k]
end,
})
return fs