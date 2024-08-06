describe('subdirs', function()
  local meta, subdirs, map, iter, init1, init1r, init1rf, td_dirs, td_dirsf, both, bothr
  setup(function()
    meta = require "meta"
    subdirs = meta.no.dirs
    map = table.map
    iter = table.iter
    init1 = table({
      "all",
      "dirinit",
      "dir",
      "filedir",
    })
    init1r = table({
      "testdata/init1/all",
      "testdata/init1/dirinit",
      "testdata/init1/dir",
      "testdata/init1/filedir",
    })
    init1rf = table({"testdata/init1"}) .. init1r
    td_dirs = table({
      "testdata/dirs/a",
      "testdata/dirs/a/a",
      "testdata/dirs/a/a/a",
      "testdata/dirs/a/b",
      "testdata/dirs/a/b/b",
      "testdata/dirs/a/c",
      "testdata/dirs/a/c/c",
      "testdata/dirs/b",
      "testdata/dirs/b/a",
      "testdata/dirs/b/a/a",
      "testdata/dirs/b/b",
      "testdata/dirs/b/b/b",
      "testdata/dirs/b/c",
      "testdata/dirs/b/c/c",
      "testdata/dirs/c",
      "testdata/dirs/c/a",
      "testdata/dirs/c/a/a",
      "testdata/dirs/c/b",
      "testdata/dirs/c/b/b",
      "testdata/dirs/c/c",
      "testdata/dirs/c/c/c",
    })
    td_dirsf = table({"testdata/dirs"}) .. td_dirs
    both = (table() .. init1) .. {
      "a",
      "b",
      "c",
    }
    bothr = (table() .. init1rf) .. td_dirsf
  end)
  it("nil", function()
    assert.same({}, map(subdirs()))
    assert.same({}, map(subdirs(nil)))
    assert.same({}, map(subdirs({})))
    assert.same({}, map(subdirs(table())))
    assert.same({}, map(subdirs(iter({}))))
  end)
  it("subdirs", function()
    assert.values(init1, map(subdirs('testdata/init1', false)))
    assert.values(init1, map(subdirs({'testdata/init1'}, false)))
    assert.values(init1, map(subdirs(table({'testdata/init1'}), false)))
    assert.values(init1, map(subdirs(iter({'testdata/init1'}), false)))

    assert.equal('', map(subdirs({'testdata/init1', 'testdata/dirs'}, false)))
    assert.values(both, map(subdirs({'testdata/init1', 'testdata/dirs'}, false)))
    assert.values(both, map(subdirs(table({'testdata/init1', 'testdata/dirs'}), false)))
    assert.values(both, map(subdirs(iter({'testdata/init1', 'testdata/dirs'}), false)))
  end)
  it("subdirs recursive", function()
    assert.equal('', map(subdirs('testdata/init1', true)))
    assert.values(init1rf, map(subdirs('testdata/init1', true)))

    assert.values(td_dirsf, map(subdirs('testdata/dirs', true)))
    assert.values(td_dirsf, map(subdirs({'testdata/dirs'}, true)))
    assert.values(td_dirsf, map(subdirs(table('testdata/dirs'), true)))
    assert.values(td_dirsf, map(subdirs(iter({'testdata/dirs'}), true)))

    assert.values(bothr, map(subdirs({'testdata/init1', 'testdata/dirs'}, true)))
    assert.values(bothr, map(subdirs(table({'testdata/init1', 'testdata/dirs'}), true)))
    assert.values(bothr, map(subdirs(iter({"testdata/init1", "testdata/dirs"}), true)))
  end)
end)
