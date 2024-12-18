describe("cache.root.meta", function()
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
    assert.equal('meta', cache.root['meta'])
    assert.equal('meta', cache.root['meta.loader'])
    assert.equal('meta', cache.root['meta/loader'])
    assert.equal('meta', cache.root[1])
    assert.equal('meta', cache.root['meta/a/b/c/d/e/f/g/h'])

    assert.equal(is, cache.root('is'))
    assert.equal(cache, cache.root('cache'))
    assert.equal('c', cache.root('files/i/c/c').x)
  end)
  it("negative", function()
    assert.is_nil(cache.root[is])
    assert.is_nil(cache.root.is)
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