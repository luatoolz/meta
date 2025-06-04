require 'meta.module'
local loader  = require 'meta.loader'
local meta    = loader 'meta'

if package.loaded.luassert then
  _=meta+'assert'
end

return meta