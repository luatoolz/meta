return {function(a, b)
  if type(a)~='table' or type(b)~='table' or #a~=#b then return false end
  local aseen, bseen = {}, {}
  for _,v in pairs(a) do aseen[v]=true end
  for _,v in pairs(b) do bseen[v]=true end
  for _,v in pairs(a) do if not bseen[v] then return false end end
  for _,v in pairs(b) do if not aseen[v] then return false end end

  return true end,
  "Expected to have same values:\nExpected:\n%s\nPassed in:\n%s\n",
  "Expected to NOT have same value:\nExpected:\n%s\nPassed in:\n%s\n"}
