require 'meta.string'
require 'meta.table'
--local pkg = ...
--local fs = require 'meta.fs'
local dir, file = require 'meta.fs.dir', require 'meta.fs.file'

local function rnd(n)
  local chars = 'qwertyyuiopassdfghjkzxcvbnm1234567890QWERTYUIOPASDFGHJKLZXCVBNM'
  local rv = {}
  for i = 1, n do table.insert(rv, chars[math.random(#chars)]) end
  return table.concat(rv, '')
end
local function createfiles(d, n)
  d = dir(d)
  for i = 1, n do file(d,rnd(8)).writer(rnd(32)) end
end
local function createdirs(d, i, files, dirs)
  i = i or 3
  if (not i) or i <= 0 then return end
  files = files or 4
  dirs = dirs or 4

  local created, cf = 0
  d = dir(d)
  local done = (not d.exists) and d.mkdirp
  created=created+(done and 1 or 0)
  cf=createfiles(d, math.ceil(math.random(files)))
  for j = 1, dirs do created=created+(createdirs(d .. rnd(8), i - 1, files, dirs) or 0) end
  return created,cf
end

return createdirs