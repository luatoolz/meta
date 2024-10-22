describe("table * is.match", function()
  local meta, is, match
  setup(function()
    meta = require "meta"
    is = meta.is
    to = meta.to
--    match = meta.match
    match = to.match
--meta.wrapper('meta.matcher') ^ string.smatcher
  end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(table))
    assert.truthy(is.callable(match.string))
  end)
  it("positive", function()
    assert.equal('a', match.string('a'))
    assert.equal('aa', match.string('aa'))
    assert.equal('aaa', match.string('aaa'))
    assert.equal('ab', match.string('ab'))
    assert.equal('abc', match.string('abc'))

    assert.equal('a', match.string(' a'))
    assert.equal('aa', match.string(' aa'))
    assert.equal('aaa', match.string(' aaa'))
    assert.equal('ab', match.string(' ab'))
    assert.equal('abc', match.string(' abc'))

    assert.equal('a', match.string('a '))
    assert.equal('aa', match.string('aa '))
    assert.equal('aaa', match.string('aaa '))
    assert.equal('ab', match.string('ab '))
    assert.equal('abc', match.string('abc '))

    assert.equal('a a', match.string('a a'))
    assert.equal('a a a', match.string('a a a'))
    assert.equal('a b', match.string('a b'))
    assert.equal('a b c', match.string('a b c'))

    assert.equal('a a', match.string(' a a'))
    assert.equal('a a a', match.string(' a a a'))
    assert.equal('a b', match.string(' a b'))
    assert.equal('a b c', match.string(' a b c'))

    assert.equal('a a', match.string('a a '))
    assert.equal('a a a', match.string('a a a '))
    assert.equal('a b', match.string('a b '))
    assert.equal('a b c', match.string('a b c '))

    assert.equal('a a', match.string(' a a '))
    assert.equal('a a a', match.string(' a a a '))
    assert.equal('a b', match.string(' a b '))
    assert.equal('a b c', match.string(' a b c '))

--[[
    assert.equal(table{}, table{} * match.string)
    assert.equal(table{}, table{''} * match.string)
    assert.equal(table{'a'}, table{'a'} * match.string)
    assert.equal(table{'a','b'}, table{'a','b'} * match.string)
    assert.equal(table{'a','b'}, table{' a ', ' b '} * match.string)
    assert.equal(table{'a','b'}, table{' a ',nil,' b '} * match.string)
--]]

--    assert.equal(table{'b'}, table{'  ',nil,' b '} * match.string)
--    assert.equal(table{'a'}, table{' a ',nil,'  '} * match.string)
  end)
  it("negative", function()
--    assert.is_nil(match.string(''))
    assert.is_nil(match.string(' '))
    assert.is_nil(match.string('  '))
    assert.is_nil(match.string('   '))
    assert.is_nil(match.string('    '))
    assert.is_nil(match.string())
    assert.is_nil(match.string())
    assert.is_nil(match.string(true))
    assert.is_nil(match.string(false))
  end)
  it("nil", function()
    assert.is_nil(match.string())
    assert.is_nil(match.string(nil))
  end)
end)