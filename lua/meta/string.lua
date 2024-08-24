require "compat53"

string.sep = string.sub(_G.package.config,1,1)
string.dot = '.'
string.msep = '%' .. string.sep
string.mdot = '%' .. string.dot
string.mmultisep = string.msep .. string.msep .. '+'

function string:basename() return (type(self)=='string' and self or ''):match("[^./]*$") end
function string:nmatch(p) return self:match(p) or '' end

-- todo: escape + unescape
function string:replace(from, to)
  if type(self)~='string' then return self end
  if type(from)~='string' then return self end
  if not (type(from)=='string' and #from>0) then return end
	return (self or ''):gsub(from, to or '') or self
end

function string:startswith(from) assert(type(self)=='string'); return type(from) == 'string' and #from<=#self and self:sub(1, #from) == from end
function string:endswith(from) assert(type(self)=='string'); return type(from) == 'string' and #from<=#self and self:sub(-#from) == from end
function string:trim() assert(type(self)=='string'); return self:match("^%s*(.-)%s*$") end
function string:capitalize()
--  assert(type(self)=='string')
  return type(self)~='string' and self or (#self>0 and self:lower():gsub("^%l", string.upper):gsub("%s%l", string.upper) or '')
end

function string.prefix(self, pre) if not pre then return self end; return self:startswith(pre) and self or (pre .. self) end
function string.suffix(self, pre) if not pre then return self end; return self:endswith(pre) and self or (self .. pre) end

function string.nzprefix(self, pre) if not pre or #self==0 then return self end; return self:startswith(pre) and self or (pre .. self) end
function string.nzsuffix(self, pre) if not pre or #self==0 then return self end; return self:endswith(pre) and self or (self .. pre) end

function string:lstrip(...)
  self=type(self)=='string' and self or tostring(self)
	local arg = {...}
	for _, from in ipairs(arg) do
		if self:startswith(from) then self=self:sub(#from+1) end
	end
	return self
end
function string:rstrip(...)
  self=type(self)=='string' and self or tostring(self)
	local arg = {...}
	for _, from in ipairs(arg) do
		if self:endswith(from) then self=self:sub(1, #self-#from) end
	end
	return self
end
function string:strip(...) return self:lstrip(...):rstrip(...) end
function string:null() return self~='' and self or nil end
function string:escape() return tostring(self):gsub("([^%w])", "%%%1"):null() end

-- self == sep, it=string
-- self == string, sep
function string:split(sep)
--	if type(sep or nil)~='string' then return {self} end
  sep=sep or ' '
  local rv = {}
  local saver = function(x, ...) table.insert(rv, x) end
  string.gsub(tostring(self) .. (sep or ' '), sep=='' and '(.)' or string.format('(.-)(%s)', string.escape(sep) or '%s+'), saver)
  return rv
end
function string:splitter()
  return function(it)
    return tostring(it):split(self)
  end
end

function string:gsplit(sep)
  return type(sep)~='string' and string.gmatch(tostring(self), '.+') or
    string.gmatch(tostring(self) .. (sep or ' '), sep=='' and '(.)' or string.format('(.-)%s', string.escape(sep) or '%s+'))
end
function string:gsplitter()
  return function(it)
    return tostring(it):gsplit(self)
  end
end

-- split by spaces by default
function string:tohash() local r={}
  for _,v in pairs(self:split()) do v=v:null(); if v then r[v]=true end end
  return r
end

-- self == sep
function string:join(...)
  assert(type(self)=='string')
  local rv={}
  for i=1,select('#', ...) do
    local o = select(i, ...)
    o=tostring(o or ''):null()
    if o then table.insert(rv, o) end
  end
  return table.concat(rv, self)
end
--[[
local function mapper(f, ...)
  local arg={...}
  local rv, it = {}, nil
  for _,v in ipairs(arg) do
    if type(v)=='string' then
      v=f(v)
      if type(v)=='string' then
        table.insert(rv, v)
      end
    end
  end
  return table.unpack(rv)
end
--]]
function string:joiner()
  return function(...)
    return self:join(...)
  end
end
function string:matcher(tobool)
  return tobool and function(it)
    return (type(it)=='string' and it:match(self)) and true or false
  end or function(it)
    if type(it)=='string' then
      return it:match(self)
    end
  end
end

if debug and debug.getmetatable and getmetatable("")~=nil then
--print( "%5.2f" % math.pi )
--print( "%-10.10s %04d" % { "test", 123 } )
  debug.getmetatable("").__mod = function(a, b)
    if not b then
      return a
    elseif type(b) == "table" then
      return string.format(a, table.unpack(b))
    else
      return string.format(a, b)
    end
  end
end
