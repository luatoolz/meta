require "compat53"
return function(...)
  local rv={}
  for i=1,select('#', ...) do
    table.insert(rv, tostring(select(i, ...)))
  end
  return table.concat(rv, ': ')
end