require "compat53"

local no = require "meta.no"
local inspect = require "inspect"
local mt = require "meta.mt"

local function save(self, k, ...)
  if rawget(((getmetatable(self) or {}).__computed or {}), '__save')~=false then rawset(self, k, ...) end; return ... end

local function computed(self, key)
  if key==nil then return nil end
  assert((type(key) == 'string' and #key > 0) or type(key) == 'number', 'meta.computed: want key string/number, got ' .. type(key))
  local __computed = mt(self).__computed
  if key then
    local f = rawget(__computed, key)
    if f then
      return save(self, key, no.assert(no.call(f, self)))
    end
  end
  return nil
end

return function(m, __computed, dosave)
  assert(type(m)=='table', 'want table, but got ' .. type(m) .. inspect(debug.traceback(m)))
  assert(type(__computed)=='table')
  rawset(__computed or {}, '__save', dosave)
  mt(m).__computed = __computed
  mt(m).__index = computed
  return m
end
