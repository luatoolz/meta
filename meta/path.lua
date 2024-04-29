require "compat53"

local conf = require "meta.conf"
local isdir = require "meta.isdir"
local sub = require "meta.sub"
local searcher = require "meta.searcher"
local sep = conf.sep

local cache = {}
local function path(m, key)
  if type(m)=='nil' then return nil end
  assert((type(m)=='string' and #m>0) or type(m)=='table', 'want string or table, got ' .. type(m))
  m=sub(m)
  assert(type(m)=='string')
  local submodule=sub(m, key)
  if cache[submodule] then return cache[submodule] end
  local dir=cache[m] or searcher(m)
  if dir then
    dir = dir:gsub('%/init%.lua$', '')
    if isdir(dir ~= '' and dir or '.') and not cache[m] then cache[m]=dir end
    if key and #dir>0 then dir = dir .. sep .. key end
    if isdir(dir) then
      cache[submodule]=dir
      return dir
    end
  end
  if not key and m:match('%/') then
    local kk = m:match("[^/]+$")
    local mm = m:gsub("%/[^/]+$", '')
    if mm .. sep .. kk == m then
      return path(mm, kk)
    end
  end
  return nil
end

return path
