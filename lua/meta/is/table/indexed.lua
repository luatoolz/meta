local ipaired = require 'meta.is.ipaired'
return function(self) return (type(self)=='table' and type(next(self))~='nil' and (ipaired(self) or type(self[1])~='nil')) and true or nil end
