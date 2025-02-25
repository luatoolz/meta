require 'meta.table'
local path = require 'meta.path'
local computed, setcomputed =
  require "meta.mt.computed",
  require "meta.mt.setcomputed"

local this = {}
return setmetatable(this, {
  append    = function(self, data) return ((data and self:open('ab')) and self.io:write(data)) and true or nil end,
  write     = function(self, data, ...) return ((data and self:open('w+b')) and self.io:write(data, ...)) and true or nil end,
  open      = function(self, ...) return self.io:open(tostring(self), ...) or nil end,
  seek      = function(self, ...) return self.io:seek(...) end,
  setvbuf   = function(self, ...) return self.io:setvbuf(...) end,
  read      = function(self, ...) return self:open('rb') and self.io:read(...) or nil end,
  flush     = function(self) return self.io:flush() end,
  close     = function(self) self:flush(); return self.io:close() end,
  lines     = function(self) return self.io.fd:lines() end,
__computed  = {
  path      = function(self) return path(self[{1,-1}]) end,
  name      = function(self) return self.path.name end,
  dir       = function(self) return self.path.base end,
  io        = function(selfio) return setmetatable({
    opened    = function(self) return io.type(self.fd)=='file' end,
    closed    = function(self) return (not self.fd) or io.type(self.fd)=="closed file" end,
    read      = function(self, orig)
      local i=orig
      i=i or self.buf or '*a'
      if i=='line' then i='*l' end
      local rv, err = self.fd:read(i)
      if type(rv)=='nil' and type(err)~='nil' then error(err) end
      if i=='*a' or type(orig)=='nil' or (
          type(i)=='number' and ((not rv) or rv=='') or #rv<i
        ) then self:close() end
      return rv
    end,
    write     = function(self, data, pos)
      if data then
        if pos then self:seek(pos) end
        return data and self.fd:write(data)
      end
      return nil
    end,
    seek      = function(self, pos, rel)
      local fd = self.fd
      if not fd then return nil end
      if type(pos)~='nil' then
        if pos==true then pos='end' end
        if pos==false then pos='cur' end
        if type(pos)=='number' then
          if pos>=0 then return assert(fd:seek(rel or 'set', pos), 'seek 1') end
          if pos <0 then return assert(fd:seek(rel or 'cur', pos), 'seek 2') end
        end
        if pos=='end' then return assert(fd:seek(pos)) end
      end
      return assert(fd:seek())
    end,
    setvbuf   = function(self, buf)
      buf=buf or 32*1024
      if buf==0 or type(buf)=='nil' or buf=='no' then buf=nil end
      self.buf = buf
      return self.fd:setvbuf(buf and 'full' or 'no', buf)
    end,
    open  = function(self, fpath, mode, buf)
      if self.fd and self.mode~=mode then assert(self:close(), 'open failed: %s (%s)'^{fpath,mode}) end
      if not self.fd then
        self.fd = assert(io.open(fpath, mode), 'error open file %s (%s)'^{fpath, mode})
        if self.fd then
          local b = mode[-1]
          self.binary = b=='b'
          self.mode = mode
          self:setvbuf(buf)
        end
      end
      return self.fd and true or nil
    end,
    flush = function(self) return self:opened() and self.buf and self.fd:flush() and true or nil end,
    close = function(self) return -self end,
  },{
    __gc    = function(self) return -self end,
    __sub   = table.delete,-- __mode='v',
    __unm   = function(self) return ((self:closed() or (self:flush() and self.fd:close()))
              and (self-{'fd','buf','mode','binary'})) and true or nil end,
  }) end,
},
__computable = {
  attr        = function(self) return self.path.attr end,
  exists      = function(self) return self.attr.mode=='file' end,
  rm          = function(self) return self.path.rm end,
  size        = function(self) return self.attr.size end,
  inode       = function(self) return self.attr.ino end,
  fd          = function(self) return self.io.fd end,
  age         = function(self) return os.time() - self.attr.modification end,

  opener      = function(self) return function(...) return self.dir.mkdir and self:open(...) end end,
  closer      = function(self) return function(...) return self:close(...) end end,
  appender    = function(self) return function(...) return self:append(...) end end,
  seeker      = function(self) return function(...) return self:seek(...) end end,
  reader      = function(self) return function(...) return self:read(...) end end,
  writer      = function(self) return function(...) return self:write(...) end end,
  appendcloser= function(self) return function(...) local rv=self:append(...); self:close(); return rv end end,
  writecloser = function(self) return function(...) local rv=self:write(...); self:close(); return rv end end,
  readcloser  = function(self) return function(...) local rv=self:read(...); self:close(); return rv end end,
  content     = function(self) return self.readcloser() end,
},
__add = function(self, v)
  if type(v)=='string' then
    self.appender(v)
  end
  return self
end,
__call = function(self, x)
  return setmetatable(x, getmetatable(self))
end,
__eq = function(a, b)
  return (type(a)==type(b) and rawequal(getmetatable(a),getmetatable(b))) and tostring(a)==tostring(b)
end,
__export = function(self) return self.content end,
__gc        = function(self) return -self.io end,
__name      = 'file',
__index = computed,
__newindex  = function(self, k, v)
  if type(k)=='nil' then
    if type(v)=='string' then
      return self.writecloser(v)
    end
  end
  setcomputed(self, k, v)
end,
__tonumber = function(self) return self.age end,
__tostring = function(self) return tostring(self.path) end,
__unm      = function(self) _=-self.io; return self.rm end,
})