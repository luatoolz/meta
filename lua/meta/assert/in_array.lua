return {function(el, a)
  if type(a)=='table' then
--    for i=1,(table.maxn and table.maxn(a) or #a) do
    for i=1,table.maxi(a) do
      local v = a[i]
      if el==v then return true end
    end
  end
  return false end,
  "Expected to be in array:\nExpected:\n%s\nPassed in:\n%s\n",
  "Expected to NOT be iin arrau:\nExpected:\n%s\nPassed in:\n%s\n"}
