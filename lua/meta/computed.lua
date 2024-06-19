require "compat53"

local no = require "meta.no"
local mt = require "meta.mt"

return function(m, __computed, __computable)
  assert(type(m)=='table', 'want table, but got ' .. type(m))
  assert(type(__computed)=='table' or type(__computable)=='table')

  mt(m).__computed = table.zcoalesce(__computed)
  mt(m).__computable = table.zcoalesce(__computable)

  mt(m).__index = no.computed
  return m
  end
