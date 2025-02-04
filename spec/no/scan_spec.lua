describe('scan', function()
  local meta, no, scan, map
  setup(function()
    meta = require "meta"
    no = require "meta.no"
    scan = no.scan
    map = table.map
    _ = meta
  end)
  it("nil", function()
    assert.same({}, map(scan()))
    assert.same({}, map(scan(nil)))
    assert.same({}, map(scan('')))
    assert.same({'testdata/init1'}, map(scan('testdata/init1')))
    assert.has('lua/meta', map(scan('meta')))
  end)
end)