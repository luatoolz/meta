describe("is.callable", function()
	local is
	setup(function()
    is = require "meta.is"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable)
    assert.truthy(is.callable(is.callable))
    assert.is_table(is.mt)
  end)
  it("positive", function()
    assert.is_true(is.callable(table))
    assert.is_true(is.callable(is))
    assert.is_true(is.callable(string.format))
    assert.is_true(is.callable(table.remove))

    assert.is_false(not is.callable(string.format))
    assert.is_true(not is.callable("some"))
  end)
  it("negative", function()
    assert.is_nil(is.callable("some"))
    assert.is_true(not is.callable(true))
    assert.is_nil(is.callable(true))
    assert.is_nil(is.callable(false))
    assert.is_nil(is.callable({}))
    assert.is_nil(is.callable({7}))
    assert.is_nil(is.callable(1))
    assert.is_nil(is.callable("1"))
  end)
  it("nil", function()
    assert.is_nil(is.callable(nil))
    assert.is_nil(is.callable())
  end)
  it("non", function()
    assert.is_true(is.non.callable(nil))
    assert.is_true(is.non.callable())
    assert.is_true(is.non.callable("some"))
    assert.is_true(is.non.callable(true))
    assert.is_true(is.non.callable(false))
    assert.is_true(is.non.callable({}))
    assert.is_true(is.non.callable({7}))
    assert.is_true(is.non.callable(1))
    assert.is_true(is.non.callable("1"))
    assert.is_nil(is.non.callable(table))
    assert.is_nil(is.non.callable(is))
    assert.is_nil(is.non.callable(string.format))
    assert.is_nil(is.non.callable(table.remove))
  end)
end)