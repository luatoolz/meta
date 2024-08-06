local indexed={['function']=true, ['table']=true, ['userdata']=true, ['CFunction']=true}
local meta, cache, typed, mt

-- get type name
return function(t, x)
  if indexed[type(x)] then
    meta = meta or require "meta"
    cache = cache or meta.cache
    typed = typed or cache.type
    mt = mt or meta.mt

    return t==typed[x] or t==typed[mt(x)] -- and true or false
  end
  return t==nil or false end
