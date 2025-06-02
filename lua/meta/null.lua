require 'compat53'
return setmetatable({},{
__name='null',
__call=function(self, ...) return self end,
--__eq=function(a,b) return (a==nil or a==null) and (b==nil or b==null) end,
__export=function(...) return nil end,
__tostring=function(...) return '' end,
})