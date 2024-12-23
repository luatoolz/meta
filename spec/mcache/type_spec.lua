describe("mcache.type", function()
	local meta, is, mcache, no
	setup(function()
    meta = require "meta"
    is = meta.is
    mcache = meta.mcache
    no = meta.no
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(mcache.type))
  end)
  it("positive", function()
    assert.equal('no', mcache.type[no])
    assert.equal('mcache', mcache.type[mcache])
    assert.equal('loader', mcache.type[meta.loader])
    assert.equal('module', mcache.type[meta.module])
  end)
  it("negative", function()
    assert.is_nil(mcache.type[''])
    assert.is_nil(mcache.type[{}])
    assert.is_nil(mcache.type[0])
    assert.is_nil(mcache.type[false])
    assert.is_nil(mcache.type[true])
  end)
  it("nil", function()
    assert.is_nil(mcache.type[nil])
  end)
end)