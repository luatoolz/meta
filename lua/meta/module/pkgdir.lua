local this = {}
local co   = require 'meta.call'
local iter = require 'meta.iter'
local path = require 'meta.path'
--local selector = require 'meta.select'
local is = {
  dir = require 'meta.is.dir',
  file = require 'meta.is.file',
  like = require 'meta.is.like',
}
_ = iter
--local last = selector[-1]
return setmetatable(this,{
__call=function(self, it, scanning) if type(it)~='nil' then
  scanning=scanning and tostring(scanning)
  if rawequal(self, this) then
    it = tostring(it)
    local dir, mask = it:match('^([^%?]*)%?([^%?]*)$')
--    if dir=='' then dir='.' end
    if (not dir) or (not mask) then return nil, 'invalid pkgdir: %s' ^ it end
    local matcher = (dir:escape() or '') .. '(.+)' .. mask:escape() .. '$'
    local unmask = '(.+)' .. mask:escape() .. '$'
    return setmetatable({path(dir), mask, string.matcher(matcher), matcher, string.matcher(unmask)}, getmetatable(self))
  else
    local _, mask, matcher, _, unmask = table.unpack(self)
    it = tostring(it)
--print('  _mod start', it, type(it), tostring(it), scanning)
    local p = path(it)
    local isdir = p.isdir
    it=tostring(it)
    if isdir then it=it .. mask end
    if p.exists and matcher(it) then
      local id = unmask(it)
      if id==scanning then return end
--print('_mod2', id)
      id=id and id:match('[^%/]+$')
--print('_mod3', id)

--      local id = type(it)=='string' and it:match('[^%/]+$') or unmask(last(a)) or last(a)
--      if id~='init' then
--print('  _mods 4 end', it, tostring(it), id);
        return tostring(it), id end
--    end
  end
end end,
__mod = function(a,b)
  local self, k = a, b
  if is.like(this, b) then self,k=b,a
    if self[3] then return self(k) end end
  local sub = self[1] and self[1]/k or nil
  local dir = (sub and sub.isdir) and sub or nil
--print('   ls ', dir, 'for', self)
  return (dir and dir.isdir) and co.wrap(function()
    for it in dir.ls do co.yieldok(self(it, dir)) end end)
end,
__div = function(self, k)
--  local testsub = type(k)=='table'
  local sub = self[1] and self[1]/(k..self[2]) or nil
  return (sub and sub.isfile and sub.exists) and tostring(sub) or nil
end,
__mul = function(a,b)
  local self,k=a,b
  if is.like(this, b) then self,k=b,a end
  if rawequal(self,this) then return self(k) end
  local sub = self[1] and self[1]/k or nil
  return (sub and sub.isdir) and sub or nil
end,
__index = function(self, k)
  local sub = self[1] and self[1]/(k..self[2]) or nil
  return (sub and sub.isfile) and sub or nil
end,
__eq = function(a, b) return tostring(a)==tostring(b) end,
__tostring = function(self) return tostring(self[1]/('?'.. self[2])) end,
})