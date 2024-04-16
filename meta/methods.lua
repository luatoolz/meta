local ignore = { ['__index']=true }
return function(o, x)
  if o==nil then return 'oo' end
  local rv = {}
  local o = getmetatable(o) or o
  if o then
    for k,v in pairs(o) do
      if not rawget(rv,k) and k:match("^__") and not ignore[k:lower()] then
        rv[k] = o[k]
      end
    end
  end
  if x then
    for k,v in pairs(x) do
      if k:match("^__") then
        rv[k] = x[k]
      end
    end
  end
  return rv
end

--[[
function class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    local m=getmetatable(self)
    if m then
        for k,v in pairs(m) do
            if not rawget(self,k) and k:match("^__") then
                self[k] = m[k]
            end
        end
    end
    return o
end

------------------------------------------------------------------

local function nestable(t)
    return setmetatable(t or {}, {
        __index = function (self, key)
            local new = nestable {}
            rawset(self, key, new)
            return new
        end
    })
end

local data = nestable {}

data.raw.a1.a2 = { foo = 'bar' }

print(data.raw.a1.a2.foo)

------------------------------------------------------------------

RootObjectType = {}
RootObjectType.__index = RootObjectType
function RootObjectType.new( o )
        o = o or {}
        setmetatable( o, RootObjectType )
        o.myOid = RootObjectType.next_oid()
        return o
end

function RootObjectType.newSubclass()
        local o = {}
        o.__index = o
        setmetatable( o, RootObjectType )
        RootObjectType.copyDownMetaMethods( o, RootObjectType )
        o.baseClass = RootObjectType
        return o
end

function RootObjectType.copyDownMetaMethods( destination, source ) -- this is the code you want
        destination.__lt = source.__lt
        destination.__le = source.__le
        destination.__eq = source.__eq
        destination.__tostring = source.__tostring
end

RootObjectType.myNextOid = 0
function RootObjectType.next_oid()
        local id = RootObjectType.myNextOid
        RootObjectType.myNextOid = RootObjectType.myNextOid + 1
        return id
end

function RootObjectType:instanceOf( parentObjectType )
        if parentObjectType == nil then return nil end
        local obj = self
        --while true do
        do
                local mt = getmetatable( obj )
                if mt == parentObjectType then
                        return self
                elseif mt == nil then
                        return nil
                elseif mt == obj then
                        return nil
                else
                        obj = mt
                end
        end
        return nil
end


function RootObjectType:__lt( rhs )
        return self.myOid < rhs.myOid
end

function RootObjectType:__eq( rhs )
        return self.myOid == rhs.myOid
end

function RootObjectType:__le( rhs )
        return self.myOid <= rhs.myOid
end

function RootObjectType.assertIdentity( obj, base_type )
        if obj == nil or obj.instanceOf == nil or not obj:instanceOf( base_type ) then
                error( "Identity of object was not valid" )
        end
        return obj
end

function set_iterator( set )
        local it, state, start = pairs( set )
        return function(...) 
                local v = it(...)
                return v
        end, state, start
end
--]]
