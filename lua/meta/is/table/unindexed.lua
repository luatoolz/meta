local maxi = require 'meta.table.maxi'
return function(self) return type(self)=='table' and type(next(self))~='nil' and maxi(self)==0 end