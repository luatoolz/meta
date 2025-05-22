return setmetatable({},{
  __call=function(x) return "loader/callable/init_table" end,
})