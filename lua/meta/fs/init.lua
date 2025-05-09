require 'meta.table'
--local co = require 'meta.call'
--local iter = require 'meta.iter'
--local selector = require 'meta.select'
local lfs = require 'lfs'

--getmetatable(io.stdout).__metatable = "IO"

local meta = require 'meta.lazy'
local is, fn, pkg = meta({'is', 'fn', 'fs'})
_ = is .. 'fs'
local _ = fn[{'n','null', 'mt','args','swap'}]
local alias = pkg.type
local match={mode=string.matcher('^[rwa]+?b?$')}
_=match

-- path: table.select(fs, {'rpath','exists','abs','cwd','type','attr','lattr','target','inode','age','size','rm','badlink','isabs','islink','ispipe','isfile','isdir','nondir','item'})
-- dir:  table.select(fs, {'ls','lsr','tree','rmtree','mkdir','rmdir','mkdirp','item'}]})
local pak = {path=true, dir=true, file=true, block=true, type=true, alias=true}

local path
local fs
fs = setmetatable({
  lfs       = lfs,

  rpath     = function(self) return tostring(self.target or self) end,
  exists    = function(self) return self.islink or (self.attr.mode and true or nil) end,
  abs       = function(self) return self.isabs and self or self(self.cwd, self[{1}]) end,

  cwd       = function(self) return lfs.currentdir() end,
  type      = function(self) return alias[self.lattr.mode or self.attr.mode] end,
  attr      = function(self) return self and lfs.attributes(tostring(self)) or {} end,
  lattr     = function(self) return self and lfs.symlinkattributes(tostring(self)) or {} end,
  mode      = function(self) return alias[self.lattr.mode or self.attr.mode] end,
  target    = function(self) path=path or fs.path; return alias[self.lattr.mode]=='link' and path(self,'..',self.lattr.target) end,
  inode     = function(self) return self.attr.ino end,
  age       = function(self) return os.time() - self.attr.modification end,
  size      = function(self) return self.attr.size end,

  rm        = function(self) return (not self.exists) or (self.isfile and os.remove(self.rpath)) or nil end,

  badlink   = function(self) return (alias[self.lattr.mode]=='link' and not self.attr.mode) and true or nil end,
  isabs     = function(self) return self[0] and true or nil end,
  islink    = function(self) return self.type=='link' or nil end,
  ispipe    = function(self) return self.type=='pipe' or nil end,
  isfile    = function(self) return self.type=='file' or nil end,
  isdir     = function(self) return self.type=='dir' or nil end,
  nondir    = function(self) return (self.type and not self.isdir) or nil end,
  item      = function(self) return (self.isdir and setmetatable(self, getmetatable(fs.dir)))
                                    or (self.isfile and setmetatable(self, getmetatable(fs.file)))
                                    or setmetatable(self, getmetatable(fs.path)) end,
-------------------------------------------------------------------------------------------------
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

,{__index=function(self, k) return table.select(self, k) or pkg[k] end,}
--]]
},{__name='fs',__index=function(self, k) return table.select(self, k) or (pak[k] and pkg[k]) end})
return fs