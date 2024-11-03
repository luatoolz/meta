describe("mt.computed", function()
	local meta, is, mt, computed
	setup(function()
    meta = require "meta"
    is = meta.is
    mt = meta.mt
    computed = mt.computed
	end)
  it("meta", function()
    assert.truthy(is)
    assert.truthy(is.callable(computed))
  end)
  it("positive", function()
    assert.is_function(computed(setmetatable({}, {a=function(...) return 777 end}), 'a'))
    local o = setmetatable({}, {
      x=function(...) return 999 end,
      __computed={
        a=function(...) return 777 end
      },
      __computable={
        b=function(...) return 888 end
      }
    })
    assert.is_function(computed(o, 'x'))
    assert.equal(888, computed(o, 'b'))
    assert.is_nil(rawget(o, 'b'))
    assert.is_nil(o.b)
    assert.equal(777, computed(o, 'a'))
    assert.equal(777, rawget(o, 'a'))
    assert.equal(777, o.a)
  end)
  it("negative", function()
    assert.is_nil(computed(nil, nil, 'a'))
    assert.is_nil(computed(nil, {}, nil))
    assert.is_nil(computed(nil, {}, 'a'))
    assert.is_nil(computed(nil, {a=888}, 'a'))
    assert.is_nil(computed({a=function(...) return 777 end}, 'a'))
    assert.is_nil(computed(''))
    assert.is_nil(computed({}))
    assert.is_nil(computed(0))
    assert.is_nil(computed(1))
    assert.is_nil(computed(false))
    assert.is_nil(computed(true))
  end)
  it("nil", function()
    assert.is_nil(computed())
    assert.is_nil(computed(nil))
    assert.is_nil(computed(nil, nil))
    assert.is_nil(computed(nil, nil, nil))
  end)
end)