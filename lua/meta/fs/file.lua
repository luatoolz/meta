require 'meta.table'
local co    = require('meta.call')
local call  = co.method
local iter  = require 'meta.iter'
local meta  = require 'meta.lazy'
local fn    = meta({'fn'})
local save  = require 'meta.table.save'
local fs    = require 'meta.fs'
local path  = require 'meta.fs.path'
local g     = getmetatable(path)
local this  = {}
local match = {
  mode      = string.matcher('^[rwa]%+?b?$'),
  block     = fs.block,
}
return setmetatable(this, {
__computable= table.merge({
  reader    = function(self) return self.isfile and co.wrap(function(buf) buf=fs.block(buf); self:open('rb', buf)
    while self.reading do co.yieldok(self:read(buf)) end end) or fn.null end,
  writer    = function(self) return self:open('w+b') and function(data, keep)
    if self.writing then return self:write(data), (not keep) and self:close() or nil end end end,  -- keep - true to keep opened, false/nil to close
  appender  = function(self) return self:open('a+b') and function(data, keep)
    if self.writing then return self:write(data), (not keep) and self:close() or nil end end end,  -- keep - true to keep opened, false/nil to close

  reading   = function(self) return (self.opened and (self.mode or '')[1]=='r') or nil end,
  writing   = function(self) local x=(self.mode or '')[1]; return self.opened and (x=='w' or x=='a') or nil end,
  binary    = function(self) return self.mode[-1]=='b' or nil end,
  opened    = function(self) return self.fd and io.type(self.fd)=='file' or nil end,
  closed    = function(self) return ((not self.fd) or io.type(self.fd)=="closed file") or nil end,
}, fs[{'cwd','attr','lattr','target','rpath','type','exists','badlink','isfile','islink','ispipe','isdir','inode','age','size','rm','isabs','abs'}]),
  open      = function(self, mode, buf)
    mode = match.mode(mode)
    buf  = match.block(buf)
    if call.opened(self) and self.mode~=mode then call.close(self) end
    if save(self, 'fd', io.open(self.rpath, mode)) then
      self.mode = mode
      self.buf  = self.buf or buf
      if self.writing and type(buf)=='number' then call.setvbuf(self.fd, buf) end
    end
    return self.fd
  end,
  eof       = function(self, buf, rv) if self.reading then
    return (rv==nil or (buf=='*a') or (type(buf)=='number' and call.read(self.fd, 0)==nil))
  end end,
  read      = function(self, buf)
    buf=buf or self.buf or '*a'
    if buf=='line' then buf='*l' end
    if self.fd then
      local rv,e = call.read(self.fd, buf)
      local eof = self:eof(buf, rv)
      if eof then call.close(self) end
      return rv,e
    end
  end,
  write     = function(self, data, pos)
    if data then
      if pos then call.seek(self, pos) end
      return data and call.write(self.fd, data) and true
    end
    return nil
  end,
  seek      = function(self, pos, rel)
    local fd = self.fd
    if fd and type(pos)~='nil' then
      if pos==true then pos='end' end
      if pos==false then pos='cur' end
      if type(pos)=='number' then
        if pos>=0 then return call.seek(fd,rel or 'set', pos) end
        if pos <0 then return call.seek(fd,rel or 'cur', pos) end
      end
      if pos=='end' then return call.seek(fd,pos) end
    end
    return call.seek(fd)
  end,
  setvbuf   = function(self, buf)
    buf=buf or 64*1024
    if buf==0 or type(buf)=='nil' or buf=='no' then buf=nil end
    self.buf = buf
    return call.setvbuf(self.fd, buf and 'full' or 'no', buf)
  end,
  flush = function(self) return self.writing and call.flush(self.fd) end,
  close = function(self) call.flush(self); local rv,err=call.close(self.fd); rawset(self,'fd',nil); self.mode=nil; self.buf=nil; return rv,err end,

__add       = g.__add,
__call      = g.__call,
__concat    = g.__concat,
__eq        = g.__eq,
__index     = g.__index,
__newindex  = g.__newindex,
__tostring  = g.__tostring,
__id        = g.__id,
__sep       = g.__sep,

__name      = 'file',
__iter      = function(self, to) return iter(self.reader, to) end,
__unm       = function(self) self:close(); return self.rm end,
})