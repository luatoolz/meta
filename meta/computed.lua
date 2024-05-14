require "compat53"

_ = require "meta.searcher"

local clone = require "meta.clone"
local inspect = require "inspect"
local mpcall = require "meta.pcall"
local mtindex = require "meta.mtindex"
local mt = require "meta.mt"

local function save(self, k, v)
--  if mt(self).__computed.__save~=false then rawset(self, k, v) end; return v end
  if rawget(((getmetatable(self) or {}).__computed or {}), '__save')~=false then rawset(self, k, v) end; return v end
--  rawset(self, k, v)
--  return v
--end

--local function newkey(self, key, value)
--  rawset(self, key, value)
--end

local function computed(self, key)
  assert((type(key) == 'string' and #key > 0) or type(key) == 'number')
  local __computed = mt(self).__computed
--  local __computed = rawget(getmetatable(self) or {}, '__computed') or {}
--  local f = ((getmetatable(self) or {}).__computed or {})[key]
--print(111)
--  local f = ((getmetatable(self) or {}).__computed or {})[key]
  if key then
    local f = rawget(__computed, key)
    if f then return save(self, key, mpcall(f, self)) end
  end

--  local __toindex = rawget(mt(self), '__toindex')
--print(inspect(__toindex), key, __toindex[key])
--  for k,v in pairs(__toindex) do
--    print('  computed:',k,v)
--  end

--  f = rawget(mt(self).__toindex, key)
--  if f then return f end
end

return function(m, __computed, dosave)
  assert(type(m)=='table', 'want table, but got ' .. type(m) .. inspect(debug.traceback(m)))
  assert(type(__computed)=='table')
  rawset(__computed or {}, '__save', dosave)
  mt(m).__computed = __computed
  mt(m).__index = computed

  return m
--[[
  local _mt = clone(m, {
    __computed = __computed,
    __index = computed,
  })
  return setmetatable({}, _mt)
--]]

--  _mt.__index = clone()
--  print(inspect(_mt))
--  print(inspect(m))

--  mt(m).__computed = __computed
--  mt(m).__index = computed

--  return setmetatable(m, mt(m))
--  return setmetatable({}, getmetatable(m))
--  return setmetatable({}, mt(m, {
--    __computed = __computed_save,
--    __index=computed
--  }))
--]]

--  mt(m).__index=m
--  mtindex(m).__index = computed

--  m.__index=computed
--  t.__index=m

--  print(inspect(t))


--  mmt.__newindex=newkey
--  mmt.__index=m
--  m.__index=computed

--print(inspect(t))
--print(inspect(t.subpath))

--local o = t('meta')
--print(o.path)
--print(inspect(t.suka))

--  return t
end
