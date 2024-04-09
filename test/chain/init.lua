local packageName, _ = ...
local meta = require "meta"
return meta.chain(
  {country="US"},
  meta.computed({
    name=function(self) return "John" end,
    last=function(self) return "Smith" end,
  }, true, true),
  meta.loader(packageName))
