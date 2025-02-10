describe('scan', function()
  local iter, no, scan, map
  setup(function()
    iter = require "meta.iter"
    no = require "meta.no"
    scan = no.scan
    map = iter.map
  end)
  it("nil", function()
    assert.same({}, map(scan()))
    assert.same({}, map(scan(nil)))
    assert.same({}, map(scan('')))
    assert.same({'testdata/init1'}, map(scan('testdata/init1')))
    assert.has('lua/meta', map(scan('meta')))
  end)
end)