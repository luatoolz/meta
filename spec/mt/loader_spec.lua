describe("mt.loader", function()
	local meta, is, mt, loader, testdata, td, instance
	setup(function()
    meta = require 'meta'
    is = meta.is ^ 'testdata'
    mt = meta.mt
    loader = mt.loader
    tdmt = require 'testdata.mt'
--    testdata = require 'testdata'
--    td = testdata.mt
--    td = require "testdata.mt"
    instance = require 'meta.module.instance'
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(mt))
    assert.truthy(is.callable(loader))
    assert.is_table(tdmt)
  end)
  it("positive", function()
--    local instance = require 'meta.module.instance'
    assert.equal('testdata/mt', instance[tdmt])
    assert.is_table(tdmt.ok)
    assert.equal('ok', tdmt.ok.x)
  end)
  it("negative", function()
    assert.is_nil(loader(nil, nil, 'a'))
    assert.is_nil(loader(nil, {}, nil))
    assert.is_nil(loader(nil, {}, 'a'))
    assert.is_nil(loader(nil, {a=888}, 'a'))
    assert.is_nil(loader(''))
    assert.is_nil(loader({}))
    assert.is_nil(loader(0))
    assert.is_nil(loader(1))
    assert.is_nil(loader(false))
    assert.is_nil(loader(true))
  end)
  it("nil", function()
    assert.is_nil(loader())
    assert.is_nil(loader(nil))
    assert.is_nil(loader(nil, nil))
    assert.is_nil(loader(nil, nil, nil))
  end)
end)