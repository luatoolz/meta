describe("cache.object", function()
	local meta, is, cache
	setup(function()
    meta = require "meta"
    is = meta.is
    cache = meta.cache
    require "meta.wrapper"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(cache.object))
  end)
  it("positive", function()
    assert.equal(meta, cache.object['meta'])
    assert.is_true(is.wrapper(cache.object['wrapper']))
    assert.equal('loader', cache.type[cache.object['loader']])
  end)
  it("negative", function()
    assert.is_nil(cache.object[''])
    assert.is_nil(cache.object[{}])
    assert.is_nil(cache.object[0])
    assert.is_nil(cache.object[false])
    assert.is_nil(cache.object[true])
  end)
  it("nil", function()
    assert.is_nil(cache.object[nil])
  end)
end)