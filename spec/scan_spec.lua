describe('scan', function()
  local meta, no, scan, map
  setup(function()
    require "meta.assert"
    meta = require "meta"
    no = meta.no
    scan = no.scan
    map = table.map
  end)
  it("nil", function()
    assert.same({}, map(scan()))
    assert.same({}, map(scan(nil)))
    assert.same({}, map(scan('')))
    assert.same({'testdata/init1'}, map(scan('testdata/init1')))
    assert.same('lua/meta', map(scan('meta'))[1])
  end)
end)
