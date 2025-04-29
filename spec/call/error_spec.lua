describe("call.errors", function()
	local is, e, call
	setup(function()
    require "meta"
    is = require 'meta.is'
    e = 'call.errors: invalid argument'
    call = require 'meta.call'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(call.errors))
  end)
  it("positive", function()
    assert.equal('a: b', call.errors('a','b'))
    assert.equal('a: true', call.errors('a',true))
    assert.equal('a: false', call.errors('a',false))
    assert.equal('a: 0', call.errors('a',0))
    assert.equal('a: 1', call.errors('a',1))

    assert.equal('a: b: c', call.errors('a', 'b', 'c'))
    assert.equal('a: b: true', call.errors('a','b', true))
    assert.equal('a: b: false', call.errors('a', 'b', false))
    assert.equal('a: b: 0', call.errors('a', 'b', 0))
    assert.equal('a: b: 1', call.errors('a', 'b', 1))
  end)
  it("negative", function()
    local nils={nil,'',{},0,1,false,true}
    for _,v in ipairs(nils) do
      assert.equal(e, select(2, call.errors(v)))
      assert.equal(e, select(2, call.errors('',v)))
      assert.equal(e, select(2, call.errors(v,'a')))
      assert.equal(e, select(2, call.errors(v,'')))
    end
  end)
  it("nil", function()
    assert.is_nil(select(2, call.errors(nil, nil)))
    assert.is_nil(select(2, call.errors(nil)))
    assert.is_nil(select(2, call.errors()))
  end)
end)