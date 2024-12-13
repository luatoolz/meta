local meta = require "meta"
return meta.factory({
  ok='factory'
},{
  ok=function(self) return 'mt' end,
},{__preindex=function(self, k)
  if k=='ok' then return 'preindex' end
end},{__postindex=function(self, k)
  if k=='ok' then return 'postindex' end
end},{__computed={
  ok=function(self) return 'computed' end,
}},{__computable={
  ok=function(self) return 'computable' end,
}})