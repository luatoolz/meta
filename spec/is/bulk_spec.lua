describe("is.bulk", function()
  local meta, iter
  setup(function()
    meta = require 'meta'
    iter = meta.iter
  end)
  it("positive", function()
    assert.not_bulk({})
    assert.not_bulk({''})
    assert.not_bulk({"x"})
    assert.not_bulk({"x", "y"})
    assert.not_bulk({1})

    assert.bulk(table{})
    assert.bulk(table())

    assert.bulk(iter({}))
    assert.bulk(iter.it(iter({})))
  end)
  it("negative", function()
    assert.not_is_bulk()
    assert.not_is_bulk(nil)
    assert.not_is_bulk(1)
    assert.not_is_bulk("")
    assert.not_is_bulk(true)
    assert.not_is_bulk(false)

    assert.not_is_bulk(meta.dir)
    assert.not_is_bulk(meta.fs.dir('testdata'))
  end)
end)