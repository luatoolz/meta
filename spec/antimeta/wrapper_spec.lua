describe("wrapper", function()
  local wrapper, is, cache
  setup(function()
    cache = require "meta.cache"
    wrapper = require "meta.wrapper"
    is = require "meta.is"
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(wrapper)
  end)
  it("require", function()
    assert.is_nil(cache.normalize.loader)
    local wrap = assert(wrapper('testdata.init3', type))
    assert.is_nil(cache.normalize.loader)
    assert.is_true(is.wrapper(wrap))
    assert.is_nil(cache.normalize.loader)
    assert.equal(type, wrap[false])
    assert.equal('testdata.init3', wrap[true])
    assert.equal(0, wrap[0])
    assert.is_nil(cache.normalize.loader)
    _ = wrap ^ is.table
    assert.is_nil(cache.normalize.loader)
    assert.equal(0, wrap[0])
    _ = wrap ^ type
    assert.is_nil(cache.normalize.loader)
    local value = 'table'
    assert.equal(table({a=value, b=value, c=value, d=value}), wrap % {'a', 'b', 'c', 'd'})
  end)
end)