require "meta.table"

local pkgname = (...) or 'meta.pkg'
local iload = require(pkgname..'.iload')

local pkg = {
  error=iload(pkgname, 'error'),
  [true]=pkgname:split('/','.'),
}

local func={error=true}
return setmetatable(pkg,{
__call=function(self, name, path)
  if self==pkg then
    if not (type(name)=='string' and #name>0 and ((type(path)=='nil') or (type(path)=='string' and #path>0 and path:endswith('.lua')))) then return nil end
    local rv=name:split('/','.')
    local n
    if type(path)=='string' and not path:endswith('/init.lua') then n=rv[#rv]; rv[#rv]=nil end
    return setmetatable({[true]=rv,[false]=n}, getmetatable(self))
  end
end,
__concat=function(self, k)
--  if type(k)=='string' and #k>0 then table.insert(rv, k) end
  local rv = table.concat(self[true], '.')
  if type(k)=='string' and #k>0 then rv=(rv..'.')..k end
  return rv
end,
__eq=function(a,b) return #a==#b and tostring(a)==tostring(b) end,
__index=function(self, k)
  if type(k)=='boolean' then return rawget(self, k) end
  if type(k)=='string' and #k>0 then
    if func[k] then return rawget(pkg, k) end
    return table.save(self, k, iload(self, k))
  end
  return nil
end,
__tostring=function(self) return self .. self[false] end,
})