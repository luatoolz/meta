return function(x)
  if type(x)=='table' then
    local mt = (getmetatable(x or {}) or {}).__index
    return type(mt)=='table' or type(mt)=='function'
  end
  return false
end
