describe("wrapper", function()
  local meta, wrapper, is, cache
  setup(function()
    meta = require "meta"
    is = meta.is ^ 'testdata'
    wrapper = meta.wrapper
    cache = meta.cache
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(wrapper)
  end)
  it("new", function()
    local l = cache.loader('testdata/init3')
    assert.not_nil(l)
    local wrap = wrapper('testdata/init3', type, 'init3')
    assert.is_true(is.callable(is.wrapper))
    assert.is_true(is.wrapper(wrap))
    assert.equal(type, wrap[false].handler)
    assert.equal(0, wrap[false].len)
    _ = wrap ^ is.table
    assert.equal(0, wrap[false].len)
    _ = wrap ^ type
    local value = 'table'
    assert.equal(table({a=value, b=value, c=value, d=value}), wrap % is.truthy)
  end)
  it("wrap3", function()
    wrap = assert(require "testdata.wrap3")
    assert.is_table(wrap)
    assert.equal('testdata/wrap3', tostring(wrap))
    assert.equal('table', wrap.a)
    assert.same({a='table',b='table'}, (wrap .. {'a','b'}) % is.truthy)
    assert.same({a='table',b='table',c='table'}, (wrap .. {'a','b','c'}) % is.truthy)
    assert.same({a='table',b='table',c='table'}, wrap % is.truthy)
    assert.keys({'a','b','c'}, wrap)
    assert.not_keys({'a','b','c','d'}, wrap)
    assert.keys({'a','b','c','d'}, wrap .. true)
    assert.same({a='table',b='table',c='table',d='table'}, wrap % is.truthy)
    assert.same({a='TABLE',b='TABLE',c='TABLE',d='TABLE'}, wrap * string.upper)
  end)
end)