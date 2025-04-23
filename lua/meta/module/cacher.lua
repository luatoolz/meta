local rev, instance, queue =
  require 'meta.module.rev',
  require 'meta.module.instance',
  require 'meta.module.iqueue'

return function(name, v)
  if name and v then rev[name]=true; instance[name]=v; return v end
  if name and not instance[package.loaded[rev[name]]] then
    print(' cacher', 'enqueue', name, #queue)
    table.insert(queue, name) end
  return v
end