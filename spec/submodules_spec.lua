describe('subfiles', function()
  local meta, submodules, map, iter, file
  setup(function()
    meta = require "meta"
    submodules = meta.no.modules
    map = table.map
    iter = table.iter
    file = {dirs=table {'a', 'b', 'c', 'i'}, files=table {a=table {'a'}, b=table {'a', 'b'}, c=table {'a', 'b', 'c'}, i=table {'a', 'b', 'c', 'd'}}}
  end)
  it("nil", function()
    assert.same({}, map(submodules()))
    assert.same({}, map(submodules(nil)))
    assert.same({}, map(submodules({})))
    assert.same({}, map(submodules(table())))
    assert.same({}, map(submodules(iter({}))))
  end)
  it("submodules", function()
    assert.values(file.dirs, map(submodules('testdata/files')))
    assert.values(file.files.a, map(submodules('testdata/files/a')))
    assert.values(file.files.b, map(submodules('testdata/files/b')))
    assert.values(file.files.c, map(submodules('testdata/files/c')))
    assert.values(file.files.i, map(submodules('testdata/files/i')))
  end)
end)
