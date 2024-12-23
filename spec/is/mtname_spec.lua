describe("is.mtname", function()
	local is
	setup(function()
    require "meta"
    is = require "meta.is"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.mtname)
    assert.truthy(is.callable(is.mtname))
  end)
  it("positive", function()
    assert.is_true(is.mtname('__name'))
    assert.is_true(is.mtname('__index'))
    assert.is_true(is.mtname('__eq'))
    assert.is_true(is.mtname('__or90'))
  end)
  it("negative", function()
    assert.is_nil(is.mtname('__'))
    assert.is_nil(is.mtname('__.'))
    assert.is_nil(is.mtname('__/'))
    assert.is_nil(is.mtname('__-'))
    assert.is_nil(is.mtname(''))
    assert.is_nil(is.mtname('x'))
    assert.is_nil(is.mtname('any'))
  end)
  it("nil", function()
    assert.is_nil(is.mtname(nil))
    assert.is_nil(is.mtname())
  end)
end)
