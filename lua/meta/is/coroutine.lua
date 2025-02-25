return function(x)
  if type(x)=='function' then
    local k,v = debug.getupvalue(x, 2)
    if k~='coro' then k,v = debug.getupvalue(x, 1) end
    return k=='coro' and type(v) == 'thread'
  end
  return type(x)=='thread'
end