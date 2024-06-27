local meta = require "meta"
return meta.object({__tostring=function(self) return self.data end,}):loader(...):instance({data='okok'})
