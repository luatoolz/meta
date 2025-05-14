require 'compat53'
require 'meta.gmt'

local tuple = {}

function tuple.n(...)       local rv = select('#', ...); return rv>0 and rv or nil end
function tuple.args(...)    local n,rv = select('#', ...),{...}; return (n==1 and type(rv[1])=='table') and rv[1] or rv end
function tuple.good(x, ...) if type(x)~='nil' then return x, ... end end

function tuple.null(x)      return nil    end
function tuple.noop(...)    return ...    end
function tuple.swap(a,b)    return b,a    end
function tuple.k(_,k)       return k,nil  end
function tuple.kk(_,k)      return k,k    end
function tuple.v(v)         return v,nil  end
function tuple.vv(v)        return v,v    end

return setmetatable(tuple, {
__call=function(self, ...)
  if rawequal(self, tuple) then return setmetatable(table.pack(...),getmetatable(self)) end
  return table.unpack(self)
end,
__index=tuple,
__pairs=ipairs,
})