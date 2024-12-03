describe("checker", function()
	local is, checker, check
	setup(function()
    require "meta"
    is = require "meta.is"
    checker = require "meta.checker"
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(checker)
    assert.truthy(is.callable(checker))
  end)
  it("positive", function()
    check = checker({["number"]=true,["boolean"]=true,["string"]=true}, type)
    assert.is_true(check[1])
    assert.is_true(check[true])
    assert.is_true(check['some'])
    assert.is_nil(check[{}])
    assert.is_nil(check[string.lower])

    local check2 = checker({["number"]=true,["boolean"]=true,["string"]=string.upper}, type)
    assert.equal('SOME', check2('some'))

    local check3 = checker({["nil"]=false}, type, true)
    assert.equal(false, check3(nil))
    assert.equal(true, check3(''))
  end)
  it("nil", function()
    assert.is_nil(checker(nil))
    assert.is_nil(checker())
    assert.is_nil(check(nil))
    assert.is_nil(check())
  end)
end)