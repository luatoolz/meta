describe("string.errors", function()
	local meta, is, e
	setup(function()
    meta = require "meta"
    is = meta.is
    e = 'string.errors: invalid argument'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(string.errors))
  end)
  it("positive", function()
    assert.equal('a: b', string.errors('a','b'))
    assert.equal('a: true', string.errors('a',true))
    assert.equal('a: false', string.errors('a',false))
    assert.equal('a: 0', string.errors('a',0))
    assert.equal('a: 1', string.errors('a',1))

    assert.equal('a: b: c', string.errors('a', 'b', 'c'))
    assert.equal('a: b: true', string.errors('a','b', true))
    assert.equal('a: b: false', string.errors('a', 'b', false))
    assert.equal('a: b: 0', string.errors('a', 'b', 0))
    assert.equal('a: b: 1', string.errors('a', 'b', 1))

--    assert.equal('a: table: 0x', string.sub(select(2, string.errors('a',{})), 1, 12))
  end)
  it("negative", function()
    local nils={nil,'',{},0,1,false,true}
    for _,v in ipairs(nils) do
      assert.equal(e, select(2, string.errors(v)))
      assert.equal(e, select(2, string.errors('',v)))
      assert.equal(e, select(2, string.errors(v,'a')))
      assert.equal(e, select(2, string.errors(v,'')))
    end
  end)
  it("nil", function()
    assert.equal(e, select(2, string.errors(nil, nil)))
    assert.equal(e, select(2, string.errors(nil)))
    assert.equal(e, select(2, string.errors()))
  end)
end)