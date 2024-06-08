local no = require "meta.no"

no.asserts("ends", function(a, b, ...)
  return (type(a)=='string' and type(b)=='string' and b:sub(-#a)==a and true or nil), ... end,
  "Expected module name ending to have value.\nExpected:\n%s\nPassed in:\n%s\n",
  "Expected module name ending not to have value.\nExpected:\n%s\nPassed in:\n%s\n")

no.asserts("in_array",  function(el, a)
  if type(a)=='table' then
    for i=1,table.maxn(a) do
      local v = a[i]
      if el==v then return true end
    end
  end
  return false end,
  "Expected to be in array:\nExpected:\n%s\nPassed in:\n%s\n",
  "Expected to NOT be iin arrau:\nExpected:\n%s\nPassed in:\n%s\n")

no.asserts("same_values",  function(a, b)
  if type(a)~='table' or type(b)~='table' or #a~=#b then return false end
  local aseen, bseen = {}, {}
  for _,v in pairs(a) do aseen[v]=true end
  for _,v in pairs(b) do bseen[v]=true end
  for _,v in pairs(a) do if not bseen[v] then return false end end
  for _,v in pairs(b) do if not aseen[v] then return false end end

  return true end,
  "Expected to have same values:\nExpected:\n%s\nPassed in:\n%s\n",
  "Expected to NOT have same value:\nExpected:\n%s\nPassed in:\n%s\n")
