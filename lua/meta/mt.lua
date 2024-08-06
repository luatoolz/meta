require "compat53"
require "meta.table"
local is = {
	boolean = function(x) return type(x)=='boolean' end,
	table = function(x) return type(x)=='table' end,
}
return function(self, ...)
  if type(self)~='table' then return nil end
	local meta = table.filter({...}, is.table)[1]
	local tocreate=table.filter({...}, is.boolean)[1]
  if meta then assert(type(meta) == 'table', 'await arg#2 table, got ' .. type(meta)) end
  if not meta then
		return getmetatable(self)
		or (tocreate and getmetatable(setmetatable(self, {})) or nil)
		or (type(tocreate)=='nil' and {})
		or nil end
  local existing = getmetatable(self)
  if not existing then
    setmetatable(self, meta)
  elseif existing ~= meta then
    for k,v in pairs(meta) do
      if rawget(existing, k)~=v then rawset(existing, k, v) end
    end
  end
  return self
end
