require "compat53"
local t = require "meta"
local no, loader, mt, cache, is, to, clone = t.no, t.loader, t.mt, t.cache, t.is, t.to, table.clone
--[[
local no = t.no
local loader = t.loader
local mt = t.mt
local cache = t.cache
local clone = t.clone
local is = t.is
--]]
local function update(self, ...)
  assert(type(self)=='table')
  for i=1,select('#', ...) do
    local o = select(i, ...)
    if type(o)=='table' then
      for _,v in ipairs(o) do table.append(self, v) end
      for k,v in pairs(o) do self[k]=v end
    end
  end
  return self
end


--[[
---------------------------------------------------------
  usage (1): call methods

  return t.object({...})
        :imports({...})
        :preindex({...})
        :postindex({...})
        :computed(...)
        :loader({...})
        :factory({})

  usage (2): assign to mt vars
  local o = t.object()
  o.__imports = {...}
  o.__computed = {...}

  o.__computable.id=function(...) return ... end
  o.__computable.id = t.db.mongo.oid

  MANDATORY: --> call o:factory()
--------------------------------------------------------]]

local function uniq_split(it)
  if type(it)=='string' then it=it:split(' ') end
  if type(it)~='table' then it=nil end
  return setmetatable(table(it):uniq():null(), nil)
end

local tables=table{'__computed', '__computable', '__imports', '__required', '__id', '__default', '__filter', '__action'}:hashed()

return mt({}, {
  mt          = function(self, it) if it then update(self.mm, it)   end; return self end,  -- static (mt) vars/func/methods
  imports     = function(self, it) if it then self.__imports=it    end; return self end,  -- imports spec (typed object vars)
  computed    = function(self, it) if it then self.__computed=it   end; return self end,  -- computed vars (saved)
  computable  = function(self, it) if it then self.__computable=it end; return self end,  -- computable vars (unsaved)
  default     = function(self, it) if it then self.__default=it    end; return self end,
  filter      = function(self, it) if it then self.__filter=it     end; return self end,
  action      = function(self, it) if it then self.__action=it     end; return self end,
  required    = function(self, it) if it then self.__required =uniq_split(it) end; return self end,
  ids         = function(self, it) if it then self.__id       =uniq_split(it) end; return self end,
  loader      = function(self, it, topreload, torecursive)
    if it then cache.loader[self.tt]=loader(it, topreload, torecursive) end; return self end,
  preindex    = function(self, f) if is.callable(f) then self.__preindex=f end;   return self end,  -- set __preindex function
  postindex   = function(self, f) if is.callable(f) then self.__postindex=f end;  return self end,  -- set __postindex function
  define      = function(self, it, name, path) if type(it)~='table' then return self end
    self:required(it[true]):ids(it._):computed(mt(it).__computed):computable(mt(it).__computable)
      :filter(mt(it).__filter)
    if mt(it).__action then
      if type(mt(it).__action)=='function' then
        local __action={__=mt(it).__action}
        mt(it).__action=nil
        self:action(__action)
      end
      if type(mt(it).__action)=='table' then
        self:action(mt(it).__action)
      end
    end
    self:mt(table.filter(mt(it), is.callable))
    if name then self.__def=name else self.__def='unknown' end
    if path then self.__name=path else self.__name='unknown' end
    local rv={}
    for k,v in pairs(it) do if type(k)=='string' then
      if type(v)=='string' then
        rv[k]=string.matcher(v=='' and '.+' or v)
      elseif type(v)=='boolean' then
        rv[k]=to.boolean
        self:default({[k]=v})
      elseif type(v)=='number' then
        if v==0 then rv[k]=to.number
        elseif is.integer(v) then
          rv[k]=t.number.integer
          self:default({[k]=v})
        else
          rv[k]=to.number
          self:default({[k]=v})
        end
      elseif is.callable(v) then rv[k]=v end end
    end
    return self:imports(rv)
  end,
  definer = function(self) return function(it, name, path) return clone(self):define(it or {}, name, path):factory() end end,
  factory     = function(this, it)
    for k,_ in pairs(tables) do this.mm[k]=this.mm[k] or {} end
    this.mm:mtremove()
    this.mm.__newindex=this.mm.__newindex or function(self, key, value)
        local f = (mt(self).__imports or {})[key]
        if is.callable(f) then
          table.save(self, key, no.call(f, value)) else
          table.save(self, key, value)
        end
      end
    this.mm.__index=this.mm.__index or no.object
    local created = mt(this.tt:mtremove(it, false), this.mm)
    if cache.loader[created] then
      cache.loader[getmetatable(created)]=cache.loader[created]
    end
    return created
  end,
  __index=function(self, key)
    assert(type(self)=='table')
    assert(type(key)~='nil')
    if type(next(self))=='nil' then return nil end
    if tables[key] then
      self.mm[key]={}
      return self.mm[key]
    end
    return mt(self)[key] or self.mm[key]
    end,
  __newindex = function(self, key, v)
    assert(type(self)=='table')
    if type(key)=='nil' or type(v)=='nil' then return end
    if type(v)=='table' then
      if type(self.mm[key])~='table' then
        self.mm[key]=setmetatable(clone(v), nil)
      else
        update(self.mm[key], v)
      end
    else
      self.mm[key]=v
    end
  end,
  __call = function(self, newmeta)
    assert(type(self) == 'table', ('await table, got %s'):format(type(self)))
    assert(type(getmetatable(self)) == 'table', ('await mt(table), got %s'):format(type(getmetatable(self))))
    return setmetatable({tt=table({}), mm=table(newmeta or {})}, getmetatable(self))
  end,
})