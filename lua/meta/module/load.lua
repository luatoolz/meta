require 'compat53'
local module
local chain = require 'meta.module.chain'
local call  = require 'meta.call'
local path  = function(...) return table.concat({...},'/') end

return function(a, ...)
  local req
  if type(a)=='function' then
    req = a
  end
  local p = req and path(...) or path(a, ...)
  req=req or require
  local mod, e

  module=module or package.loaded['meta.module']
  if type(module)=='table' then
    for _,cur in pairs(chain) do
      mod = (module(path(cur, p)) or {}).ok
      if mod then return mod.load end end
  else
    for _,cur in pairs(chain) do
      local name = path(cur, p):gsub('%/+','.')
      local pl = package.loaded[name]
      if type(pl)~='nil' and type(pl)~='number' and (type(pl)~='userdata' or getmetatable(pl)) then return pl end
    end
    for _,cur in pairs(chain) do
      local name = path(cur, p):gsub('%/+','.')
      mod, e = call.pcall(req,name)
      if mod then return mod, e end end end
  return nil, 'module not found: '..p end