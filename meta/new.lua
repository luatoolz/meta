return function(self, t) return setmetatable(t or {}, getmetatable(self) or {}) end
