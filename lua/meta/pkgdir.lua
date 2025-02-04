local this = {}
local co   = require 'meta.call'
local path = require 'meta.path'

return setmetatable(this,{
__call=function(self, it) if type(it)=='string' then
  local dir, mask = it:match('([^%?]*)%?([^%?]*)')
  if dir=='' then dir='.' end
  if (not dir) or (not mask) then return nil, 'invalid pkgdir: %s' % it end
  local matcher = dir:escape() .. '(.+)' .. mask:escape() .. '$'
  return setmetatable({path(dir), mask, string.matcher(matcher), matcher}, getmetatable(self))
end end,
__mod = function(dir, self)
  if getmetatable(self)==getmetatable(this) then
    local r = self[3](tostring(dir)) and true or nil
    return r
  end
  return nil
end,
__iter = function(self)
  return co.wrap(function()
    for it in self[1].lsr do
      co.yieldok(self[3](tostring(it)), it, it.dir)
    end
  end)
end,
__eq = function(a, b) return tostring(a)==tostring(b) end,
__tostring = function(self) return tostring(self[1]/('?' .. self[2])) end,
})