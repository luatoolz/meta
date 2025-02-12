require "compat53"
require "meta.gmt"
require "meta.math"

string.slash  = '/'
string.sep    = string.sub(_G.package.config,1,1)
string.dot    = '.'
string.mslash = '%' .. string.slash
string.msep   = '%' .. string.sep
string.mdot   = '%' .. string.dot
string.mmultisep = string.msep .. string.msep .. '+'

local is = {
  callable = require "meta.is.callable",
}

-- todo: escape + unescape
function string:replace(from, to)
  if type(self)~='string' then return self end
  if type(from)~='string' then return self end
  if not (type(from)=='string' and #from>0) then return end
	return (self or ''):gsub(from, to or '') or self
end

function string:startswith(from) return type(self)=='string' and type(from)=='string' and #from<=#self and self:sub(1, #from)==from end
function string:endswith(from) return type(self)=='string' and type(from)=='string' and #from<=#self and self:sub(-#from) == from end
function string:trim() return type(self)=='string' and self:match("^%s*(.-)%s*$") end
function string:capitalize() return type(self)=='string' and #self>0 and self:lower():gsub("^%l", string.upper):gsub("%s%l", string.upper) or '' end

function string.prefix(self, pre) if not pre then return self end; return self:startswith(pre) and self or (pre .. self) end
function string.suffix(self, pre) if not pre then return self end; return self:endswith(pre) and self or (self .. pre) end
function string:nmatch(p) return self:match(p) or '' end
function string:matches(...)
  local argz, rv = {...}, {}
  for _,p in ipairs(argz) do
    if type(p)=='string' and p~='' then
      local r = self:match(p)
      if r then table.insert(rv, r) end
    end
    if type(p)=='table' then
      for _,pp in ipairs(p) do
        if type(pp)=='string' and pp~='' then
          local r = self:match(pp)
          if r then table.insert(rv, r) end
        end
      end
      end
    end
  return rv
end

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
function string:null() if type(self)=='string' and self~='' then return self end end
function string:escape() return tostring(self):gsub("([^%w])", "%%%1"):null() end

function string:strip(...) return self:lstrip(...):rstrip(...) end
function string:stripper(to)
  if type(self)=='string' then return function(it) if type(it)=='string' then return it:gsub(self, to or '') end end end
  if type(self)=='table' then
    return function(it)
      if type(it)=='string' then
        for _,v in ipairs(self) do
          if type(v)=='string' or type(v)=='function' then
            it = it:gsub(v, '', 1)
          end
        end
        return it:null()
      end
    end
  end
end

local function saver(t)
  t=t or {}
  return function(x)
    if type(x)~='nil' then table.insert(t, x) else return t end
  end
end

-- self == sep, it=string
-- self == string, sep
function string:split(...)
	if type(self)~='string' or self=='' then return end
  local sep, len = ..., select('#', ...)
  if len>1 then sep={...} end
  sep=sep or ' '
  if type(sep)=='table' then
    if #sep==0 then return nil end
    for i=1,#sep do if type(sep[i])~='string' then return nil end end
  end
  local rv = {}
  if type(sep)=='table' then
    sep=table.concat(sep, '')
    string.gsub(self, '([^%s]+)' % string.escape(sep), saver(rv))
  elseif type(sep)=='string' then
    string.gsub(sep=='' and self or (self .. (sep or ' ')), sep=='' and '(.)' or string.format('(.-)(%s)', (sep~='' and sep~=' ') and string.escape(sep) or "[%s\n]+"), saver(rv))
  end
  return rv
end

function string.splitter(...)
  local sep, len = ..., select('#', ...)
  if len>1 then sep={...} end
  return function(it)
    if type(it)=='string' then
      return it:split(sep)
    end
  end
end

function string:gsplit(sep)
  return type(sep)~='string' and string.gmatch(tostring(self), '.+') or
    string.gmatch(tostring(self) .. (sep or ' '), sep=='' and '(.)' or string.format('(.-)%s', string.escape(sep) or '%s+'))
end

function string:gsplitter()
  return function(it)
    if type(it)=='string' then
      return it:gsplit(self)
    end
  end
end

-- split by spaces by default
function string:tohash() local r={}
  for _,v in pairs(self:split() or {}) do v=v:null(); if v then r[v]=true end end
  return r
end

-- self == sep
function string:join(...)
  assert(type(self)=='string')
  local multi, last
  if #self>0 then
    multi=string.escape(self)..'+'
    last=string.escape(self)..'+$'
  end
  local rv={}
  local a={...}
  if #a==1 and type(a[1])=='table' then a=a[1] end
  for i=1,#a do
    local o=a[i]
    if type(o)=='string' then
      o=o:null()
      if o then table.insert(rv, o) end
    end
  end
  rv=table.concat(rv, self) or ''
  if multi then rv=rv:gsub(multi, self):gsub(last, '') end
  return rv:null()
end

function string:joiner()
  return function(...)
    return self:join(...)
  end
end

function string:smatcher(compare)
  return (not compare) and function(it)
    if type(it)=='nil' then return end
    if type(it)=='number' then it=tostring(it):null() end
    if type(it)=='string' then
      return it:match(self)
    end
  end or function(it) if type(it)=='string' then
    return it:match(self)==it or nil end end end

function string:gmatcher()
  return function(it)
    it=tostring(it):null()
    if type(it)=='string' then
      return it:gmatch(self)
    end
    return function() return end
  end
end

function string.matcher(pat, compare)
  local self=pat
  if (not compare) and type(self)=='function' then return self end
  if type(self)=='string' then return self:smatcher(compare) end
  if type(self)=='table' or type(self)=='function' then --or type(self)=='boolean' then
    return function(it)
      if type(it)=='nil' then
        return end
      if type(it)=='boolean' then
--        if compare and type(self)=='boolean' then return self==it end
        return end
      if type(it)=='number' or (getmetatable(it or {}) or {}).__tostring then
        it=tostring(it):null()
      end
      if type(it)=='string' then
        if type(self)=='function' and compare then return self(it)==it or nil end
        local rv, any = it
        for _,v in ipairs(self) do
          if type(v)=='boolean' then any=v
          elseif type(v)=='function' or (type(v)=='table' and (getmetatable(v) or {}).__call) then
            rv = v(rv)
          elseif type(v)=='string' then
            rv = rv:match(v)
            if rv and any then
              if compare then return rv==v or nil end
              return rv end
          end
        end
        if compare then return rv==it or nil end
        return rv
      end
    end
  end
end

function string:formatter()
  assert(type(self)=='string', 'require string as formatter argument')
  local i=0; for it in self:gmatch('%%') do i=i+1 end
  return function(...)
    if i==0 then return self end
    assert(i<=select('#', ...), 'string.formatter: require %d args: %s' % {i, self})
    if i==select('#', ...) then
      return self:format(...)
    else
      return self:format(table.unpack(table.pack(...), 1, i))
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
  debug.getmetatable("").__mul = function(a, b)
    if not b then
      return a
    elseif is.callable(b) then
      return b(a)
    end
  end
  debug.getmetatable("").__index = function(s, i)
    if type(i)=='table' and #i==1 and type(i[1])=='number' then
      i=i[1]
    end
    if type(i)=='number' then
      i=math.index(i, s)
      return s:sub(i, i) or ''
    end
    if type(i)=='table' and #i==2 and type(i[1])=='number' and type(i[2])=='number' then
      i[1]=math.index(i[1], s)
      i[2]=math.index(i[2], s)
      return s:sub(i[1], i[2]) or ''
    end
    return string[i]
  end
end

string.meta = string.smatcher('^([^/.%s]+)[/.](%S-([^/.%s]+))$')

function string.stringer(...)
  local rv={...}
  for i=1,#rv do
    rv[i]=tostring(rv[i])
  end
  return rv
end

function string:error(...)
  if type(self)~='string' or self=='' or select('#', ...)==0 or select(1, ...)=='' then return nil, 'string.error: invalid argument' end
  local rv={self, ...}
  for i=1,#rv do
    rv[i]=tostring(rv[i])
  end
  return nil, table.concat(rv, ': ')
end

function string:assert(x, ...)
  if type(self)~='string' or self=='' or select('#', ...)==0 or select(1, ...)=='' then return nil, 'string.assert: invalid argument' end
  local rv={self, ...}
  for i=1,#rv do rv[i]=tostring(rv[i]) end
  return assert(x, table.concat(rv, ': '))
end
