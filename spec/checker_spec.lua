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

    local check4 = checker({
      string=function(x) return x end,
      table=function(x) if #x>0 then return table.concat(x, '.') end end,
    }, type, '')
    assert.equal('', check4(nil))
    assert.equal('', check4(''))
    assert.equal('x', check4('x'))
    assert.equal('', check4({}))
    assert.equal('a', check4({'a'}))
    assert.equal('a.b', check4({'a','b'}))

    local parts = checker({
      table=function(x) return #x>0 and #x or nil end,
    }, type, '-')
    local check5 = checker({
      string=function(x) return x:split('.') end,
      table=function(x) return x end,
    }, type, parts)
    assert.equal(nil, check5(nil))
    assert.equal(nil, check5(''))
    assert.equal(1, check5('x'))
    assert.equal('-', check5({}))
    assert.equal(1, check5({'a'}))
    assert.equal(2, check5({'a','b'}))
  end)
  it("nil", function()
    assert.is_nil(checker(nil))
    assert.is_nil(checker())
    assert.is_nil(check(nil))
    assert.is_nil(check())
  end)
end)