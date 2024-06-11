require "compat53"

local no = require "meta.no"
local mt = require "meta.mt"

local function computable(self, t, key)
  if type(t)=='nil' or type(key)=='nil' then return nil end
  assert((type(key)=='string' and #key > 0) or type(key) == 'number', 'meta.computed: want key string/number, got ' .. type(key))
  assert(type(t)=='table', 'meta.computed: want table, got ' .. type(t))
  if t and key then
    local f = rawget(t, key)
    if no.callable(f) then
      return no.assert(no.call(f, self))
    end
  end
  return nil
  end

local function computed(self, key)
  return rawget(mt(self), key) or
  computable(self, mt(self).__computable, key) or
  no.save(self, key, computable(self, mt(self).__computed, key)) end

return function(m, __computed, __computable)
  assert(type(m)=='table', 'want table, but got ' .. type(m))
  assert(type(__computed)=='table' or type(__computable)=='table')
  if type(__computed)=='table' and next(__computed)~=nil then
    mt(m).__computed =  no.mergekeys(__computed, mt(m).__computed)
  end
  if type(__computable)=='table' and next(__computable)~=nil then
    mt(m).__computable = no.mergekeys(__computable, mt(m).__computable)
  end
  mt(m).__index = computed
  return m
  end
