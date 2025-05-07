describe("table.index", function()
  local index
  setup(function()
    index = require "meta.mt.i"
  end)
  it("index", function()
    assert.equal(2, index(table {'testdata', 'test_symlink'}, -1))
    assert.equal(1, index(table {'testdata', 'test_symlink'}, -2))
  end)
  it("interval", function()
    assert.equal('test_symlink', table{'testdata', 'test_symlink'}[2])
    assert.equal('test_symlink', table{'testdata', 'test_symlink'}[-1])
    assert.equal('testdata', table{'testdata', 'test_symlink'}[-2])

    assert.same({'testdata'}, table{'testdata', 'test_symlink'}[{1,-2}])
    assert.same({'testdata', 'test_symlink'}, table{'testdata', 'test_symlink'}[{1,-1}])
    assert.same({'testdata', 'test_symlink'}, table{'testdata', 'test_symlink'}[{1}])
    assert.same({'testdata', 'test_symlink'}, table{'testdata', 'test_symlink'}[{}])

    assert.same({'testdata', 'test_symlink'}, table{[0]='0', 'testdata', 'test_symlink'}[{}])
    assert.same({[0]='0', 'testdata', 'test_symlink'}, table{[0]='0', 'testdata', 'test_symlink'}[{0}])
  end)
end)