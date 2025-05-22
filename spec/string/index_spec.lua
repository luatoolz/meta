describe("string.index", function()
  local s
  setup(function()
    require "meta.string"
    s = 'test_symlink'
  end)
  it("interval", function()
    assert.is_nil(s[0])
    assert.equal('e', s[2])
    assert.equal('k', s[-1])
    assert.equal('m', s[-5])

    assert.equal('test_symlin', s[{1,-2}])
    assert.equal('test_symlink', s[{1,-1}])
    assert.equal('st_symli', s[{3,-3}])
    assert.equal('test_symlink', s[{1}])
    assert.equal('test_symlink', s[{}])

    s = ''
    assert.is_nil(s[0])
    assert.is_nil(s[1])
    assert.is_nil(s[-1])
    assert.is_nil(s[{}])
    assert.is_nil(s[{1}])
    assert.is_nil(s[{-1}])
    assert.is_nil(s[{0}])
  end)
end)