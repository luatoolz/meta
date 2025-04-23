describe("mt.loader", function()
	local meta, is, mt, loader, td, testdata, instance, chain, iq, rev
	setup(function()
    meta = require 'meta'
    iq = require 'meta.module.iqueue'
    chain = require 'meta.module.chain'
assert.is_nil(chain.testdata)
    is = meta.is ^ 'testdata'
assert.not_nil(chain.testdata)
    mt = meta.mt
    loader = mt.loader
    print(' iq1', iq)

--    testdata = require 'testdata'
--    td = testdata.mt
    instance = require 'meta.module.instance'
    rev = require 'meta.module.rev'

    td = require "testdata.mt"
    print(' iq2', iq)
--    for k,v in pairs(iq) do print(' iq', k, v) end
print(' name of td', instance[td], instance['testdata.mt'], instance['testdata/mt'], rev['testdata.mt'],
type(package.loaded['testdata.mt']), type(package.loaded['testdata/mt']))
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(mt))
    assert.truthy(is.callable(loader))
    assert.is_table(td)
  end)
  it("positive", function()
--    local instance = require 'meta.module.instance'
    assert.equal('testdata/td', instance[td])
    assert.equal('ok', (td.ok or {}).x)
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