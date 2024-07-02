local indexed={['function']=true, ['table']=true, ['userdata']=true, ['CFunction']=true}
local meta, cache, typed, mt

-- is typed
return function(x)
  if indexed[type(x)] then
    meta = meta or require "meta"
    cache = cache or meta.cache
    typed = typed or cache.typename
    mt = mt or meta.mt

    return typed[x]
  end
  return nil end
