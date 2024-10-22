local t = require "meta"
return t.object({
--  ok=function(self) return 'mt' end,
}):preindex(
--function(self, k) if k=='ok' then return 'preindex' end end
):postindex(function(self, k)
  if k=='ok' then return 'postindex' end
end):computed({
--  ok=function(self) return 'computed' end,
}):computable({
--  ok=function(self) return 'computable' end,
}):loader(...):factory({
--  ok='factory'
})
