describe("module.options", function()
	local meta, opt
	setup(function()
    meta = require 'meta'
    _ = meta.is ^ 'testdata'
    opt = require 'meta.module.options'
	end)
  it("meta", function()
    assert.callable(opt)
    assert.is_table(opt.meta)
    assert.is_true(opt.meta.recursive)
    assert.is_table(opt.meta.set)
    assert.is_function(opt.meta.set.recursive)

    assert.is_table(opt.testdata)
    assert.is_true(opt.testdata.recursive)
    assert.is_table(opt.testdata.set)
    assert.is_function(opt.testdata.set.recursive)

    assert.is_function(opt.assert.handler)
  end)
  it("get/set", function()
    local td = opt.testdata
    assert.is_true(td.recursive)
    assert.equal(td.set, td.set.recursive(false))
    assert.is_false(td.recursive)
    assert.equal(td.set, td.set.recursive(true))
    assert.is_true(td.recursive)
    assert.equal(td.set, td.set.recursive(nil))
    assert.is_true(td.recursive)
    td.recursive=false
    assert.is_false(td.recursive)
    td.recursive=true
    assert.is_true(td.recursive)
    td.recursive=false
    assert.is_false(td.recursive)
    td.recursive=nil
    assert.is_true(td.recursive)

    local mod = meta.module
    mod('testdata/ok').handler='red'
    assert.equal('red', mod('testdata/ok').opt.handler)
    mod('testdata/ok').opt.handler='green'
    assert.equal('green', mod('testdata/ok').opt.handler)
    assert.equal('green', mod('testdata/ok').opt.handler)
    mod('testdata/ok').opt.handler='white'
    assert.equal('white', mod('testdata/ok').opt.handler)
    mod('testdata/ok').opt.handler=nil
  end)
end)