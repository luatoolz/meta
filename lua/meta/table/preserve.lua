require 'meta.gmt'
local mt=getmetatable
local gt
local function gettable()
  gt=gt or ((mt(table) or {}).__call and table)
  return gt and gt()
end
return function(self, alt) return (type(self)=='table' and mt(self) and mt(self).__preserve) and setmetatable({},mt(self) or mt(table)) or alt or gettable() end