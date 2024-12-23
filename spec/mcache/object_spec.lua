describe("mcache.object", function()
	local meta, is, mcache, wrapper
	setup(function()
    meta = require "meta"
    is = meta.is
    mcache = meta.mcache
    wrapper = require "meta.wrapper"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(mcache.object))
  end)
  it("positive", function()
    assert.equal(meta, mcache.object['meta'])
    assert.is_true(is.wrapper(mcache.object['wrapper']))
    assert.equal('loader', mcache.type[mcache.object['loader']])
  end)
  it("negative", function()
    assert.is_true(rawequal(wrapper, meta.wrapper))
    assert.is_nil(mcache.object[''])
    assert.is_nil(mcache.object[{}])
    assert.is_nil(mcache.object[0])
    assert.is_nil(mcache.object[false])
    assert.is_nil(mcache.object[true])
  end)
  it("nil", function()
    assert.is_nil(mcache.object[nil])
  end)
end)