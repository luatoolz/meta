describe("match.meta", function()
  local meta, is, match
  setup(function()
    meta = require "meta"
    is = meta.is
    match = meta.mt.match
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(table))
    assert.truthy(is.callable(match.meta))
  end)
  it("positive", function()
    assert.same({'meta', 'to/match', 'match', n=3}, table.pack(match.meta('meta/to/match')))
    assert.same({'meta', 'to.match', 'match', n=3}, table.pack(match.meta('meta.to.match')))
    assert.same({'meta', 'is/has/value', 'value', n=3}, table.pack(match.meta('meta/is/has/value')))
  end)
  it("negative", function()
    assert.is_nil(match.meta(''))
    assert.is_nil(match.meta(' '))
    assert.is_nil(match.meta('  '))
    assert.is_nil(match.meta('   '))
    assert.is_nil(match.meta('    '))
    assert.is_nil(match.meta())
    assert.is_nil(match.meta())
    assert.is_nil(match.meta(true))
    assert.is_nil(match.meta(false))
    assert.is_nil(match.meta('meta.to.match  meta.match.t'))
  end)
  it("nil", function()
    assert.is_nil(match.meta())
    assert.is_nil(match.meta(nil))
  end)
end)