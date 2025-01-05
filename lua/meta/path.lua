require 'meta.table'
local computed = require 'meta.computed'
local checker = require 'meta.checker'
local paths = require 'paths'

local this = {}
local sep  = '/'

local has_tostring = function(x) return type((getmetatable(x) or {}).__tostring)~='nil' or nil end
local is = {
  string   = function(s) return type(s)=='string' or nil end,
  stringer = checker({table=has_tostring, userdata=has_tostring, number=true, boolean=true}, type),
  this     = function(x) return rawequal(getmetatable(this), getmetatable(x)) end,
  plain    = function(x) return type(x)=='string' and not x:match('%s%s' % {'%', sep}) end,
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
  open   = function(self, mode) return io.open(self.path, mode) end,
  write  = function(self, data, pos)
    if (not data) or #data==0 then return 0 end
    local wr, e, rv, sz
    wr, e = self.writer, nil; if not wr then return wr, e end
    if type(pos)=='number' then rv, e = wr:seek('set', pos); if e and not rv then wr:close(); return rv, e end end
    if data and #data>0 then rv, e = wr:write(data); sz=#data or 0; if e and not rv then wr:close(); return rv, e end end
    if rv then rv,e = wr:flush(); if e and not rv then wr:close(); return rv, e end end
    wr:close()
    return sz
  end,
  append = function(self, data)
    if (not data) or #data==0 then return 0 end
    local wr, e, rv, sz
    wr, e = self.appender, nil; if not wr then return wr, e end
    if data and #data>0 then rv, e = wr:write(data); sz=#data or 0; if e and not rv then wr:close(); return rv, e end end
    if rv then rv,e = wr:flush(); if e and not rv then wr:close(); return rv, e end end
    wr:close()
    return sz
  end,
__computed = {
  cwd    = function(self) return (not self.isabs) and paths.cwd() end,
},
__computable = {
  path   = function(self) return tostring(self) end,
  ext    = function(self) return paths.extname(self.path) end,
  exists = function(self) return self.isfile or self.isdir end,

  root   = function(self) return self[1] and self[1]:match('^/+') end,
  drive  = function(self) return self[1] and self[1]:match('%a%:[%/%\\]?') end,
  isabs  = function(self) return (self.root or self.drive) and true end,
  abs    = function(self) return self.isabs and self or self(self.cwd, self) end,

  isdir  = function(self) return paths.dirp(self.path) or nil end,
  isfile = function(self) return paths.filep(self.path) or nil end,

  rm     = function(self) return self.isfile and os.remove(self.path) end,
  mkdir  = function(self) return self.isdir or paths.mkdir(self.path) end,
  rmdir  = function(self) return self.isdir and paths.rmdir(self.path) end,
  rmall  = function(self) return self.isdir and paths.rmall(self.path, 'yes') end,

  items  = function(self) return self.isdir and paths.files(self.path, function(n) return n~='.' and n~='..' end) end,
  dirs   = function(self) return self.isdir and paths.iterdirs(self.path) end,
  files  = function(self) return self.isdir and paths.iterfiles(self.path) end,

  reader = function(self) return self:open('rb') end,
  writer = function(self) return self:open('w+b') end,
  appender = function(self) return self:open('a+b') end,

  size   = function(self) local r=self.reader; if r then return r:seek('end'), r:close() end end,
  content = function(self) local r=self.reader; if r then return r:read('*a'), r:close() end end,
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
  for v in splitter(it) do _ = self + v end
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