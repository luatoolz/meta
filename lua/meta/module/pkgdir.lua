require 'meta.table'
local co   = require 'meta.call'
local iter = require 'meta.iter'
local path = require 'meta.fs.path'
local dir  = require 'meta.fs.dir'
local is = {
  dir = require 'meta.is.fs.dir',
  file = require 'meta.is.fs.file',
  like = require 'meta.is.like',
}
local this = {}
return setmetatable(this,{
__call=function(self, it, scanning) if type(it)~='nil' and it~='' then
  scanning=scanning and tostring(scanning)
  if rawequal(self, this) then
    local pdir, mask = it:match('^([^%?]*)%?([^%?]*)$')
    if (not pdir) or (not mask) then return nil, 'invalid pkgdir: (%s)' ^ it end
    local matcher = (pdir:escape() or '') .. '(.+)' .. mask:escape() .. '$'
    local unmask = '(.+)' .. mask:escape() .. '$'
    return setmetatable({path(pdir), mask, string.matcher(matcher), matcher, string.matcher(unmask)}, getmetatable(self))
  else
    local _, mask, matcher, _, unmask = table.unpack(self)
    it = tostring(it)
    local p = path(it)
    local isdir = p.isdir
    it=tostring(it)
    if isdir then it=it .. mask end
    if p.exists and matcher(it) then
      local id = unmask(it)
      if id==scanning then return end
      id=id and id:match('[^%/]+$')
      return tostring(it), id
    end
  end
end end,
__eq = function(a, b) return tostring(a)==tostring(b) end,
__index = function(self, k)
  local sub = self[1] and self[1]..(k..self[2]) or nil
  return (sub and sub.isfile) and sub or nil
end,
__name = 'pkgdir',
__tostring = function(self) return tostring(self[1]..('?'.. self[2])) end,

__div = function(self, k)
  is.module=is.module or require('meta.module')
  if type(k)=='string' or is.module(k) then
  local sub = self[1] and self[1]..(k..self[2]) or nil
  return (sub and sub.isfile and sub.exists) and tostring(sub) or nil
end end,
__mod = function(a,b)
  local self, k = a, b
  if is.like(this, b) then self,k=b,a
    if self[3] then return self(k) end end
  local sub = self[1] and self[1]..k or nil
  local d = (sub and sub.isdir) and dir(sub) or nil
  return d and co.wrap(function()
    for it in iter(d.ls) do co.yieldok(self(it, d)) end end)
end,
__mul = function(a,b)
  local self,k=a,b
  if is.like(this, b) then self,k=b,a end
  if rawequal(self,this) then return self(k) end
  local sub = self[1] and self[1]..k or nil
  return (sub and sub.isdir) and sub or nil
end,
})