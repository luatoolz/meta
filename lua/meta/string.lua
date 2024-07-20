require "compat53"
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

function string.lstrip(s, ...)
  self=type(self)=='string' and self or tostring(self)
	local arg = {...}
	for _, from in ipairs(arg) do
		if s:startswith(from) then s=s:sub(#from+1) end
	end
	return s
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

function string:escape_pattern() return self and self:gsub("([^%w])", "%%%1") or self end

function string:split(sep)
  local rv = {}
  local saver = function(x, ...) table.insert(rv, x) end
  string.gsub(self .. (sep or ' '), sep=='' and '(.)' or string.format('(.-)(%s)', string.escape_pattern(sep) or '%s+'), saver)
  return rv
end

function string:zjoin(...)
  assert(type(self)=='string')
  local rv={}
  for i=1,select('#', ...) do
    local o = select(i, ...)
    o=tostring(o or ''):null()
    if o then table.insert(rv, o) end
  end
  return #rv>0 and table.concat(rv, self) or nil
end


function string.unescape_html(str)
  str = string.gsub( str, '&apos;', "'" )
  str = string.gsub( str, '&lt;', '<' )
  str = string.gsub( str, '&gt;', '>' )
  str = string.gsub( str, '&quot;', '"' )
  str = string.gsub( str, '&q;', '"' )
  str = string.gsub( str, '&a;', '&' )
  str = string.gsub( str, '&s;', "'" )
  str = string.gsub( str, '&g;', '>' )
  str = string.gsub( str, '&l;', '<' )
--  str = string.gsub( str, '&#(%d+);', function(n) return string.char(n) end )
--  str = string.gsub( str, '&#x(%d+);', function(n) return string.char(tonumber(n,16)) end )
  str = string.gsub( str, '&amp;', '&' ) -- Be sure to do this after all others
  return str
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
