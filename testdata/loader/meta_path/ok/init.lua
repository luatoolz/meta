
return setmetatable({message='ok'}, {
  __tostring = function(self) return string.upper(self.message) end,
  __call = function(self, a) return tostring(self) end,
})
