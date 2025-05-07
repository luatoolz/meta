local pkg = ...
local meta = require 'meta'
local is = meta.is
local fs = meta.fs
local path, dir, file = fs.path, fs.dir, fs.file

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
  pkg:assert(fs.isdir(d), 'dir not found: %s' ^ d)

  i = i or 3
  if (not i) or i <= 0 then return end
  files = files or 4
  dirs = dirs or 4

  d = dir(d)
  createfiles(d, math.ceil(math.random(files)))
  for j = 1, dirs do createdirs(d .. rnd(8), i - 1, files, dirs) end
end

return createdirs