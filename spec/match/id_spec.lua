describe("match.id", function()
  local meta, is, match
  setup(function()
    meta = require "meta"
    is = meta.is
    match = meta.mt.match
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(table))
    assert.truthy(is.callable(match.id))
  end)
  it("positive", function()
    assert.equal('pic.same/module', match.id('meta/pic.same/module'))
    assert.equal('loader', match.id('meta.loader'))
    assert.equal('loader', match.id('meta/loader'))
    assert.equal('loader2/noinit', match.id('testdata/loader2/noinit'))
  end)
  it("negative", function()
    assert.is_nil(match.id('meta'))
    assert.is_nil(match.id(''))
    assert.is_nil(match.id(' '))
    assert.is_nil(match.id('  '))
    assert.is_nil(match.id('   '))
    assert.is_nil(match.id('    '))
    assert.is_nil(match.id(true))
    assert.is_nil(match.id(false))
  end)
  it("nil", function()
    assert.is_nil(match.id())
    assert.is_nil(match.id(nil))
  end)
end)