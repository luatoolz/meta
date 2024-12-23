describe("wrapper", function()
  local meta, wrapper, is, mcache
  setup(function()
    meta = require "meta"
    is = meta.is ^ 'testdata'
    wrapper = require "meta.wrapper"
    mcache = require "meta.mcache"
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(wrapper)
    assert.is_function(mcache.normalize.loader)
  end)
  it("new", function()
    local l = assert(mcache.loader('testdata.init3'))
    assert.not_nil(l)
    local wrap = assert(wrapper(l, type))
    assert.is_true(is.callable(is.wrapper))
    assert.is_true(is.like(wrapper,wrap))
    assert.is_true(is.wrapper(wrap))

    assert.equal(type, wrap[false])
    assert.equal(0, wrap[0])
    _ = wrap ^ is.table
    assert.equal(0, wrap[0])
    _ = wrap ^ type
    local value = 'table'
    assert.same({a=value, b=value, c=value, d=value}, wrap % {'a','b','c','d'})
  end)
  it("wrap3", function()
    local wrap = assert(require "testdata.wrap3")
    _ = is ^ 'testdata'
    assert.is_table(wrap)
    assert.equal('wrap3', tostring(wrap))
    assert.equal(type, wrap[false])
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