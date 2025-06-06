describe("mt.computable", function()
	local meta, is, mt, computable
	setup(function()
    meta = require "meta"
    is = meta.is
    mt = meta.mt
    computable = mt.computable
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(computable))
  end)
  it("positive", function()
    assert.equal(777, computable({}, {a=function(...) return 777, 888 end}, 'a'))
    assert.same({777}, {computable({}, {a=function(...) return 777, 888 end}, 'a')})
  end)
  it("negative", function()
    assert.is_nil(computable(nil, nil, 'a'))
    assert.is_nil(computable(nil, {}, nil))
    assert.is_nil(computable(nil, {}, 'a'))
    assert.is_nil(computable(nil, {a=888}, 'a'))
    assert.is_nil(computable(''))
    assert.is_nil(computable({}))
    assert.is_nil(computable(0))
    assert.is_nil(computable(1))
    assert.is_nil(computable(false))
    assert.is_nil(computable(true))
  end)
  it("nil", function()
    assert.is_nil(computable())
    assert.is_nil(computable(nil))
    assert.is_nil(computable(nil, nil))
    assert.is_nil(computable(nil, nil, nil))
  end)
  end)