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
    assert.is_table(opt.testdata)
    assert.is_true(opt.testdata.recursive)
  end)
  describe("get/set", function()
    local td = opt.testdata
    it("recursive", function()
      assert.is_true(td.recursive)
      td.recursive=false
      assert.is_false(td.recursive)
      td.recursive=true
      assert.is_true(td.recursive)
      td.recursive=nil
      assert.is_true(td.recursive)
      td.recursive=false
      assert.is_false(td.recursive)
      td.recursive=true
      assert.is_true(td.recursive)
      td.recursive=false
      assert.is_false(td.recursive)
      td.recursive=nil
      assert.is_true(td.recursive)
    end)
    it("preload", function()
      assert.is_false(td.preload)
      td.preload=true
      assert.is_true(td.preload)
      td.preload=nil
      assert.is_false(td.preload)
      td.preload=false
      assert.is_false(td.preload)
      td.preload=true
      assert.is_true(td.preload)
      td.preload=false
      assert.is_false(td.preload)
      td.preload=nil
      assert.is_false(td.preload)
    end)
    it("handler", function()
      local mod = require 'meta.module'
      mod('testdata/ok').handler='red'
      assert.equal('red', mod('testdata/ok').opt.handler)
      assert.equal('red', mod('testdata/ok').handler)
      mod('testdata/ok').opt.handler='green'
      assert.equal('green', mod('testdata/ok').opt.handler)
      assert.equal('green', mod('testdata/ok').opt.handler)
      mod('testdata/ok').opt.handler='white'
      assert.equal('white', mod('testdata/ok').opt.handler)
      mod('testdata/ok').opt.handler=nil
    end)
  end)
end)