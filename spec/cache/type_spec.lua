describe("cache.type", function()
	local meta, is, cache, no
	setup(function()
    meta = require "meta"
    is = meta.is
    cache = meta.cache
    no = meta.no
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(cache.type))
  end)
  it("positive", function()
    assert.equal('no', cache.type[no])
    assert.equal('cache', cache.type[cache])
    assert.equal('loader', cache.type[meta.loader])
    assert.equal('module', cache.type[meta.module])
  end)
  it("negative", function()
    assert.is_nil(cache.type[''])
    assert.is_nil(cache.type[{}])
    assert.is_nil(cache.type[0])
    assert.is_nil(cache.type[false])
    assert.is_nil(cache.type[true])
  end)
  it("nil", function()
    assert.is_nil(cache.type[nil])
  end)
end)