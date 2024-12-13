local meta = require "meta"
return meta.factory({data='okok',q='init4'},{__tostring=function(self) return self.data end,})