describe("is.root", function()
	local meta, is
	setup(function()
    meta = require "meta"
    is = meta.is
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.root)
    assert.truthy(is.callable(is.root))
  end)
  it("positive", function()
    assert.is_true(is.root('meta'))
    assert.is_true(is.root('luassert'))
    assert.is_true(is.root('testdata'))
    assert.is_true(is.root('meta.seen'))
    assert.is_true(is.root('meta.wrapper'))
    assert.is_true(is.root('meta.is'))
  end)
  it("negative", function()
    assert.is_nil(is.root(false))
    assert.is_nil(is.root(true))
    assert.is_nil(is.root(77))
    assert.is_nil(is.root(0))
    assert.is_nil(is.root(string.upper))
  end)
  it("nil", function()
    assert.is_nil(is.root(nil))
    assert.is_nil(is.root())
  end)
end)