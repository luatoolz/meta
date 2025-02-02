return function(x)
  if type(x)=='function' then
    local k,v = debug.getupvalue(x, 2)
    return k=='co' and type(v) == 'thread'
  end
  return type(x)=='thread'
end