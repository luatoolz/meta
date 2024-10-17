describe("table.nextstring", function()
	local meta, is
	setup(function()
    meta = require "meta"
    is = meta.is
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(table.nextstring))
  end)
  it("positive", function()
    local test = function(t) return setmetatable(t, {__pairs=function(self) return table.nextstring, self, nil end}) end
    local a = test({[true]={x='y'}, [false]={a='b'}, a=1, b=2, c=3, d=4})

    local rv={}
    for k,v in pairs(a) do rv[k]=v end
    assert.same({a=1,b=2,c=3,d=4}, rv)
  end)
end)