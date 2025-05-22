require 'meta.module'
local call    = require 'meta.call'
local loader  = require 'meta.loader'
local meta    = loader 'meta'

if package.loaded.luassert then
  call(meta.assert)
end

return meta