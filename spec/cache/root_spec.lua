describe("cache.root", function()
	local meta, is, cache
	setup(function()
    meta = require "meta"
    is = meta.is
    cache = meta.cache
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(cache.root))
    assert.equal(true, cache.conf.root.ordered)
  end)
  it("positive", function()
    assert.equal(true, cache.root['meta'])
    assert.equal(true, cache.root['meta.loader'])
    assert.equal(true, cache.root['meta/loader'])
--    assert.equal('some long string', cache.root('some long string'))
    assert.equal('meta', cache.root[1])
  end)
  it("negative", function()
    assert.is_nil(cache.root[''])
    assert.is_nil(cache.root[{}])
    assert.is_nil(cache.root[0])
    assert.is_nil(cache.root[false])
    assert.is_nil(cache.root[true])
  end)
  it("nil", function()
    assert.is_nil(cache.root[nil])
  end)
end)