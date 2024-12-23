local found
return function(o)
  found=found or package.loaded['meta.mcache'] or package.loaded['meta/mcache']
  if found then
    local rv
    if type(o)=='string' and #o>0 then rv=found.existing[o] end
    if type(o)=='table' and getmetatable(o) then rv=found[o] end
    return rv and true
  end end