require 'meta.is'
require 'meta.module'
require 'meta.pkg'
local loader  = require 'meta.loader'
local meta    = loader 'meta'

if package.loaded.luassert then
  _=meta+'assert'
end

return meta