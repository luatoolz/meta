require "compat53"

local conf = require "meta.conf"
local path = require "meta.path"
local isdir = require "meta.isdir"
local sub = require "meta.sub"

local sep = conf.sep
local function fi(a, ...) return a end
local function onlyjoin(x, key) if type(x)=='string' and type(key)=='string' and #x>0 and #key>0 then return x .. sep .. key end end
local function striplua(m) return type(m)=='string' and fi(fi(m:gsub('init.lua$', '', 1)):gsub('.lua$', '', 1)) or m end
local function strip(m)
  if type(m)=='nil' then return m end
  assert(type(m)=='string')
  m = striplua(m)
  if m:match('%/') then return fi(m:gsub("%/[^/]*$", '', 1)) end
  if m:match('%.') then return fi(m:gsub("%.[^.]*$", '', 1)) end
  return ''
end

-- if key: return basedir(m)/key
-- if key==nil: basedir(m)
local function dir(m, key)
  if type(m)=='table' and rawget(m, 'origin') then m=rawget(m, 'origin') end
  assert(type(m)=='string')
  m=sub(m)
  if key then return isdir(path(m, key), true) or isdir(onlyjoin(striplua(path(m)), key), true) end
  local o = striplua(path(m))
	local p = striplua(path(strip(m)))

  return isdir(o, true) or isdir(p, true)
end

return dir
