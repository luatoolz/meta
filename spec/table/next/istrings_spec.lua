describe("table.next.istrings", function()
	local meta, is, map, istrings
	setup(function()
    meta = require "meta"
    is = meta.is
    map = meta.iter.map
    istrings = require 'meta.table.next.istrings'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(istrings))
  end)
  it("positive", function()
    local test = function(t) return setmetatable(t, {__pairs=function(self) return istrings, self, nil end}) end
    local a = test({[true]={x='y'}, [false]={a='b'}, a=1, b=2, c=3, d=4, 'a','b','c'})
    assert.same({'a','b','c',a=1,b=2,c=3,d=4}, map(a))
  end)
end)