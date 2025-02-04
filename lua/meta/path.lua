require 'meta.table'
local co = require 'meta.call'
--local iter = require 'meta.iter'
local computed = require 'meta.computed'
local checker = require 'meta.checker'
local paths = require 'paths'
local lfs = require"lfs"
local dir, file

local this = {}
local sep  = string.sep

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
  plain    = function(x) return type(x)=='string' and not x:match('%s%s' % {'%', sep}) end,
  callable = require 'meta.is.callable',
}
local stringer = function(x) return is.stringer(x) and tostring(x) or x end
local splitter = function(it)
  local x = stringer(it)
  if type(x)=='function' then return x end
  if x=='' or x=='/' then x={x} end
  if type(x)=='table' and #x>0 then return table.iter(x) end
  if type(x)=='string' then
    if x:match('^/+') then return table.iter({'/', x:gmatch('[^/]+')}) end
    return x:gmatch('[^/]+')
  end
  return function() return nil end
end

return computed(this, {
__computed = {
  cwd       = function(self) return (not self.isabs) and lfs.currentdir() end,
},
__computable = {
-- universal
  attr      = function(self) return lfs.symlinkattributes(self.path) or lfs.attributes(self.path) or {} end,
  target    = function(self) return self.islink and this(self.base, self.attr.target) end,
  mode      = function(self) return self.attr.mode end,

  name      = function(self) return self[-1] end,
  basedir   = function(self) return string.join('/',self(self[{1,-2}])) end,
  base      = function(self) return self(self[{1,-2}]) end,

  path      = function(self) return tostring(self) end,
  ext       = function(self) return self.path:match('%.([^%.]*)$') end,
  exists    = function(self) return self.attr.mode and true end,

-- linux/win both possible
  root      = function(self) return self[1] and self[1]:match('^[%/%\\]+') end,

-- linux/win both possible in some network tools; \Device\HarddiskVolume2, d:\, d:/, \\srv\x, //srv/x, "\\srv\with space"\
  drive     = function(self) return self[1] and self[1]:match('^(%a)%:[%/%\\]?') end,
  netunc    = function(self) return self[1] and self[1]:match('^%"?([%/%\\][%/%\\][^%/%\\]+[%/%\\][^%"%/%\\]+)[%/%\\]*%"?') end,

-- windows only, \\?\, \\?\Volume{...}\, etc
  sysunc    = function(self) return self[1] and self[1]:match('^(%\\%\\?%??%\\?[^%\\]+)%\\?') end,

-- any unc does apply
  isabs     = function(self) return (self.root or self.drive) and true end,
  abs       = function(self) return self.isabs and self or self(self.cwd, self) end,

  isdir     = function(self) return self.mode=='directory' end,
  isfile    = function(self) return self.mode=='file' end,
  islink    = function(self) return self.mode=='link' end,
  isspecial = function(self) return special[self.mode] end,

-- dir items
  items     = function(self) return self.isdir and paths.files(self.path, function(n) return n~='.' and n~='..' end) end,
  dirs      = function(self) return self.isdir and paths.iterdirs(self.path) end,
  files     = function(self) return self.isdir and paths.iterfiles(self.path) end,

  lsr       = function(self) return co.wrap(function()
    for it in self.items do
      local p = self/it
      co.yield(p)
      if p.isdir then
        for el in p.lsr do co.yield(el) end
      end
    end
  end) end,

  mkdir     = function(self) return self.isdir or  lfs.mkdir(self.path) end,
  rmdir     = function(self) return self.isdir and lfs.rmdir(self.path) end,

  rmitem    = function(self) return self.rm or self.rmdir end,
  rm        = function(self) return (self.isfile or self.islink) and os.remove(self.path) end,

-- file items
  reader    = function(self) return self:open('rb') end,
  writer    = function(self) return self:open('w+b') end,
  appender  = function(self) return self:open('a+b') end,

  size      = function(self) return self.isfile and self.attr.size end,
  content   = function(self) local r=self.reader; if r then return r:read('*a'), r:close() end end,

-- typed
  clone     = function(self) return {} .. self end,
  instance  = function(self) return self.isfile and self.file or (self.isdir and self.dir) or self end,

  file      = function(self)
    file = file or package.loaded['meta.file'] or require 'meta.file'
    return file(self.clone) end,
  dir       = function(self)
    dir = dir or package.loaded['meta.dir'] or require 'meta.dir'
    return dir(self.clone) end,
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
  for v in splitter(it) do table.append(self, v) end
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
__mod = function(self, it)
  if type(it)=='string' then it=string.matcher(it) end
  return self.isdir and table.filter(self.items, it) or {}
end,
__mul = function(self, it)
  if type(it)=='string' then it=string.matcher(it) end
  return self.isdir and table.map(self.items, it) or {}
end,
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
__tostring = function(self) return table.concat(self, sep):gsub('^/+','/') end,
})