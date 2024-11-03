describe("string.error", function()
	local meta, is, e
	setup(function()
    meta = require "meta"
    is = meta.is
    e = 'string.error: invalid argument'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(string.error))
  end)
  it("positive", function()
    assert.equal('a: b', select(2, string.error('a','b')))
    assert.equal('a: true', select(2, string.error('a',true)))
    assert.equal('a: false', select(2, string.error('a',false)))
    assert.equal('a: 0', select(2, string.error('a',0)))
    assert.equal('a: 1', select(2, string.error('a',1)))

    assert.equal('a: b: c', select(2, string.error('a', 'b', 'c')))
    assert.equal('a: b: true', select(2, string.error('a','b', true)))
    assert.equal('a: b: false', select(2, string.error('a', 'b', false)))
    assert.equal('a: b: 0', select(2, string.error('a', 'b', 0)))
    assert.equal('a: b: 1', select(2, string.error('a', 'b', 1)))

    assert.equal('a: table: 0x', string.sub(select(2, string.error('a',{})), 1, 12))
  end)
  it("negative", function()
    local nils={nil,'',{},0,1,false,true}
    for _,v in ipairs(nils) do
      assert.equal(e, select(2, string.error(v)))
      assert.equal(e, select(2, string.error('',v)))
      assert.equal(e, select(2, string.error(v,'a')))
      assert.equal(e, select(2, string.error(v,'')))
    end
  end)
  it("nil", function()
    assert.equal(e, select(2, string.error(nil, nil)))
    assert.equal(e, select(2, string.error(nil)))
    assert.equal(e, select(2, string.error()))
  end)
end)