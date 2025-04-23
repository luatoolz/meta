-- function table:stringpairs() return table.nextstring, self end

describe("table.next.string", function()
	local meta, is, map, nextstring
	setup(function()
    meta = require "meta"
    is = meta.is
    map = meta.iter.map
    nextstring = require 'meta.table.next.string'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(nextstring))
  end)
  it("positive", function()
    local test = function(t) return setmetatable(t, {__pairs=function(self) return nextstring, self, nil end}) end
    local a = test({[true]={x='y'}, [false]={a='b'}, a=1, b=2, c=3, d=4})
    assert.same({a=1,b=2,c=3,d=4}, map(a))
  end)
end)