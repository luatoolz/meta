local mt = require 'meta.gmt'
return function(t) if type(t)=='table' then
  local pairz, ipairz = mt(t).__pairs, mt(t).__ipairs
  return (pairz==ipairs or ipairz) and true or nil
end end