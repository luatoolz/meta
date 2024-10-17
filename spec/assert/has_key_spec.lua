local name, yes, no = "has_key", {'a',{a=true}}, {'a','b'}
describe(name, function()
	local falsy
	setup(function()
    require "meta"
    falsy = "not_" .. name
	end)
  it("exists", function()
    assert.not_nil(package.loaded.luassert, "luassert package not loaded")
    assert.not_nil(assert.callable)
    assert.callable(assert[name])
    assert.callable(assert[falsy])
  end)
  it("positive", function()
    if assert[name] then
      if type(yes)=='table' and #yes>0 then
        assert[name](table.unpack(yes))
      else
        assert[name](yes)
      end
    end
  end)
  it("negative", function()
    if assert[falsy] then
      if type(no)=='table' and #no>0 then
        assert[falsy](table.unpack(no))
      else
        assert[falsy](no)
      end
    end
  end)
  it("nil", function()
    if assert[falsy] then
      assert[falsy](nil)
      assert[falsy]()
    end
  end)
end)
