require "meta"
local date=require"date"
local mt = getmetatable(date())
mt.__export=function(self) return math.floor((self:toutc() - date.epoch()):spanseconds()) end
mt.__tonumber=mt.__export
return date
