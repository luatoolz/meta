describe("has.values", function()
	local meta, is, has
	setup(function()
    meta = require "meta"
    is = meta.is
    has = is.has
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.values)
    assert.truthy(is.callable(has.values))
  end)
  it("positive", function()
    assert.truthy(has.values({}, {}))
    assert.truthy(has.values({'a'}, {'a'}))
    assert.truthy(has.values({'a', 'b'}, {'b', 'a'}))
    assert.truthy(has.values({'a', 'b'}, {'a', 'b'}))

    assert.truthy(has.values({'file', 'all', 'filedir'}, {'file', 'all', 'filedir'}))
    assert.truthy(has.values({'file', 'all', 'filedir'}, table{'file', 'all', 'filedir'}))

    assert.truthy(has.values({'file', 'all', 'filedir'}, {'filedir', 'file', 'all'}))
    assert.truthy(has.values({'file', 'all', 'filedir'}, table{'filedir', 'file', 'all'}))
  end)
  it("negative", function()
    assert.falsy(has.values({'a'}, {}))
    assert.falsy(has.values({'a'}, {'b'}))
  end)
  it("nil", function()
    assert.falsy(has.values(nil, nil))
    assert.falsy(has.values(nil))
    assert.falsy(has.values())
  end)
end)