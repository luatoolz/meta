describe("is.iterable", function()
	local meta, is
	setup(function()
    meta = require "meta"
    is = meta.is
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.iterable)
    assert.truthy(is.callable(is.iterable))
  end)
  it("positive", function()
    -- pairs iter ipairs no mt
    assert.is_true(is.iterable({}))
    assert.is_true(is.iterable({7}))
    assert.is_true(is.iterable(table()))
    assert.is_true(is.iterable(table))
    assert.is_true(is.iterable(is))
    assert.is_true(is.iterable(meta))
    assert.is_true(is.iterable(meta.loader))
    assert.is_true(is.iterable(meta.seen))
    assert.is_true(is.iterable(meta.cache))
  end)
  it("negative", function()
    assert.is_nil(is.iterable("some"))
    assert.is_nil(is.iterable(true))
    assert.is_nil(is.iterable(1))
    assert.is_nil(is.iterable("1"))
    assert.is_nil(is.iterable(table.remove))
  end)
  it("nil", function()
    assert.is_nil(is.iterable(nil))
    assert.is_nil(is.iterable())
  end)
end)