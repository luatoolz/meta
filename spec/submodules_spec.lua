describe('subfiles', function()
  local meta, submodules, map, iter, file
  setup(function()
    require "meta.assert"
    meta = require "meta"
    submodules = meta.no.modules
    map = table.map
    iter = table.iter
    file = {
      files=table{
        a=table{'a'},
        b=table{'a', 'b'},
        c=table{'a', 'b', 'c'},
        i=table{'a', 'b', 'c', 'd'},
      }
    }
  end)
  it("nil", function()
    assert.same({}, map(submodules()))
    assert.same({}, map(submodules(nil)))
    assert.same({}, map(submodules({})))
    assert.same({}, map(submodules(table())))
    assert.same({}, map(submodules(iter({}))))
  end)
  it("submodules", function()
    assert.same_values(file.files.a, map(submodules('testdata/files/a')))
    assert.same_values(file.files.b, map(submodules('testdata/files/b')))
    assert.same_values(file.files.c, map(submodules('testdata/files/c')))
    assert.same_values(file.files.i, map(submodules('testdata/files/i')))
  end)
end)
