describe("mcache.type", function()
	local meta, is, mcache, mtype
	setup(function()
    meta = require "meta"
    is = meta.is
    mcache = meta.mcache
    mtype = require 'meta.module.type'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(mcache.type))
  end)
  it("positive", function()
    assert.equal('mcache', mtype(mcache))
    assert.equal('loader', mtype(meta.loader))
    assert.equal('module', mtype(meta.module))
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