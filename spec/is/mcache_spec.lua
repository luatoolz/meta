describe("is.mcache", function()
	local meta, is
	setup(function()
    meta = require "meta"
    is = require "meta.is"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.mcache)
    assert.truthy(is.callable(is.mcache))
  end)
  it("positive", function()
    assert.is_true(is.mcache(meta.mcache.type))
    assert.is_true(is.mcache('type'))
  end)
  it("negative", function()
    assert.is_nil(is.mcache({}))
    assert.is_nil(is.mcache(0))
    assert.is_nil(is.mcache(''))
    assert.is_nil(is.mcache(false))
    assert.is_nil(is.mcache(true))
  end)
  it("nil", function()
    assert.is_nil(is.mcache(nil, nil))
    assert.is_nil(is.mcache(nil))
    assert.is_nil(is.mcache())
  end)
end)