require "compat53"

local sep = string.sub(_G.package.config,1,1)
local dot = '.'
local msep = '%' .. sep
local mdot = '%' .. dot
local mmultisep = '%' .. sep .. '%' .. sep .. '+'

string.sep, string.dot, string.msep, string.mdot, string.mmultisep = sep, dot, msep, mdot, mmultisep

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
function string:escape() return tostring(self):gsub("([^%w])", "%%%1"):null() end

-- self == sep, it=string
function string:split(it)
	if type(self)~='string' then return {it} end
  local rv = {}
  local saver = function(x, ...) table.insert(rv, x) end
  string.gsub(tostring(it) .. (self or ' '), self=='' and '(.)' or string.format('(.-)(%s)', string.escape(self) or '%s+'), saver)
  return rv
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
function string:matcher()
  return function(it)
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
