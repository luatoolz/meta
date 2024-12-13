describe("checker", function()
	local is, checker
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
  describe("positive", function()
    it("type.nil", function()
      local check = checker({["number"]=true,["boolean"]=true,["string"]=true}, type)
      assert.is_true(check[1])
      assert.is_true(check[true])
      assert.is_true(check['some'])
      assert.is_nil(check[{}])
      assert.is_nil(check[string.lower])

      assert.is_nil(check(nil))
      assert.is_nil(check())
    end)
    it("type.nil", function()
      local check = checker({["nil"]=false}, type, true)
      assert.equal(false, check(nil))
      assert.equal(true, check(''))
    end)
    it("mt.nil", function()
      local check = checker({table=checker({['nil']=true},function(x) return type(getmetatable(x)) end)}, type)
      assert.is_true(check({}))
      assert.is_nil(check(checker))

      assert.is_nil(check(''))
      assert.is_nil(check(7))
      assert.is_nil(check(function() end))

      assert.is_nil(check(nil))
      assert.is_nil(check())
    end)
    it("mt.nil #table", function()
      local check = checker({table={getmetatable,type,{['nil']=true}}}, type)
      assert.is_true(check({}))
      assert.is_nil(check(checker))

      assert.is_nil(check(''))
      assert.is_nil(check(7))
      assert.is_nil(check(function() end))

      assert.is_nil(check(nil))
      assert.is_nil(check())
    end)
    it("mt.nil #table checker", function()
      local check = checker({table={getmetatable,checker({['nil']=true},type)}}, type)
      assert.is_true(check({}))
      assert.is_nil(check(checker))

      assert.is_nil(check(''))
      assert.is_nil(check(7))
      assert.is_nil(check(function() end))

      assert.is_nil(check(nil))
      assert.is_nil(check())
    end)
    it("string.upper", function()
      local check = checker({["number"]=true,["boolean"]=true,["string"]=string.upper}, type)
      assert.equal('SOME', check('some'))

      assert.is_nil(check(nil))
      assert.is_nil(check())
    end)
    it("table.concat", function()
      local check = checker({
        string=function(x) return x end,
        table=function(x) if #x>0 then return table.concat(x, '.') end end,
      }, type, '')
      assert.equal('', check(''))
      assert.equal('x', check('x'))
      assert.equal('', check({}))
      assert.equal('a', check({'a'}))
      assert.equal('a.b', check({'a','b'}))

      assert.equal('', check(nil))
      assert.equal('', check())
    end)
    it("parts", function()
      local parts = checker({
        table=function(x) return #x>0 and #x or nil end,
      }, type, '-')
      local check = checker({
        string=function(x) return x:split('.') end,
        table=function(x) return x end,
      }, type, parts)
      assert.equal(1, check('x'))
      assert.equal('-', check({}))
      assert.equal(1, check({'a'}))
      assert.equal(2, check({'a','b'}))

      assert.equal(nil, check(''))

      assert.is_nil(check(nil))
      assert.is_nil(check())
    end)
  end)
  it("nil", function()
    assert.is_nil(checker(nil))
    assert.is_nil(checker())
  end)
end)