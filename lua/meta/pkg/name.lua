local meta=require "meta"
return function(x) if x then return (meta.module:pkg(x) or {}).name end end