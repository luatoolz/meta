local indexed={['function']=true, ['table']=true, ['userdata']=true, ['CFunction']=true}
local meta, cache, typed, factory, mt

-- is typed
return function(x)
  if indexed[type(x)] then
    meta = meta or require "meta"
    cache = cache or meta.cache
    typed = typed or cache.type
    factory=factory or cache.instance
    mt = mt or meta.mt

    return factory[x] and true or false
  end
  return nil end
