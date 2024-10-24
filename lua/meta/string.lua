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

local is = {callable = function(o) return (type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call) == 'function')) end}

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
  if type(self)=='string' then return function(it) return it:gsub(self, to or '') end end
  if type(self)=='table' then
    return function(it)
      if type(it)=='string' then
        for _,v in ipairs(self) do
          if type(v)=='string' or type(v)=='function' then
            it = it:gsub(v, '', 1)
          end
        end
        return it
      end
    end
  end
end

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
    if type(it)=='string' then
      return it:split(self)
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
  return table.concat(rv, self):null()
end

function string:joiner()
  return function(...)
    return self:join(...)
  end
end

function string:smatcher(compare)
  return (not compare) and function(it)
    if type(it)=='nil' then return end
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
--        if type(self)=='boolean' then return self==it end
        return end
      if type(it)=='number' or (getmetatable(it) or {}).__tostring then
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
end

string.meta   = string.smatcher('^([^/.%s]+)[/.](%S-([^/.%s]+))$')
