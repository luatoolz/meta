return setmetatable({},{
  __call=function(x) return "loader/callable/table" end,
})