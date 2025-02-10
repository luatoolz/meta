describe("string.index", function()
  local s
  setup(function()
    require "meta.string"
    s = 'test_symlink'
  end)
  it("interval", function()
    assert.equal('', s[0])
    assert.equal('e', s[2])
    assert.equal('k', s[-1])
    assert.equal('m', s[-5])

    assert.same('test_symlin', s[{1,-2}])
    assert.same('test_symlink', s[{1,-1}])
    assert.same('st_symli', s[{3,-3}])
    assert.same('test_symlink', s[{1}])
    assert.same('test_symlink', s[{}])

    s = ''
    assert.equal('', s[0])
    assert.equal('', s[1])
    assert.equal('', s[-1])
    assert.equal('', s[{}])
    assert.equal('', s[{1}])
    assert.equal('', s[{-1}])
    assert.equal('', s[{0}])
  end)
end)