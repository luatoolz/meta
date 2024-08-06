describe('subfiles', function()
  local meta, no, subfiles, map, iter, file
  setup(function()
    meta = require "meta"
    no = meta.no
    subfiles = no.files
    map = table.map
    iter = table.iter
    file = {
      files=table{
        a=table{'a.lua'},
        b=table{'a.lua', 'b.lua'},
        c=table{'a.lua', 'b.lua', 'c.lua'},
        i=table{
          a=table{'init.lua', 'a.lua'},
          b=table{'init.lua', 'a.lua', 'b.lua'},
          c=table{'init.lua', 'a.lua', 'b.lua', 'c.lua'}
        }
      }
    }
  end)
  it("nil", function()
    assert.same({}, map(subfiles()))
    assert.same({}, map(subfiles(nil)))
    assert.same({}, map(subfiles({})))
    assert.same({}, map(subfiles(table())))
    assert.same({}, map(subfiles(iter({}))))
  end)
  it("subfiles", function()
    assert.values(file.files.a, map(subfiles('testdata/files/a')))
    assert.values(file.files.a, map(subfiles({'testdata/files/a'})))
    assert.values(file.files.a, map(subfiles(table({'testdata/files/a'}))))
    assert.values(file.files.a, map(subfiles(iter({'testdata/files/a'}))))

    assert.values(file.files.b, map(subfiles('testdata/files/b')))
    assert.values(file.files.b, map(subfiles({'testdata/files/b'})))
    assert.values(file.files.b, map(subfiles(table({'testdata/files/b'}))))
    assert.values(file.files.b, map(subfiles(iter({'testdata/files/b'}))))

    assert.values(file.files.c, map(subfiles('testdata/files/c')))
    assert.values(file.files.c, map(subfiles({'testdata/files/c'})))
    assert.values(file.files.c, map(subfiles(table({'testdata/files/c'}))))
    assert.values(file.files.c, map(subfiles(iter({'testdata/files/c'}))))
  end)
end)
