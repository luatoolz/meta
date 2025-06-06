describe("is.number.znegative", function()
  local is
  setup(function()
    require 'meta'
    is = require 'meta.is'
  end)
  it("meta", function()
    assert.callable(is.number.znegative)
  end)
  it("positive", function()
    for i=1,512 do
      assert.is_true(is.number.znegative(-i))
    end
    assert.is_true(is.number.znegative(0))
    assert.is_true(is.number.znegative(-1))
  end)
  it("is.number.znegative", function()
    assert.is_nil(is.number.znegative("0"))
    assert.is_nil(is.number.znegative("-1"))
    assert.is_nil(is.number.znegative(false))
    assert.is_nil(is.number.znegative(true))
    assert.is_nil(is.number.znegative(math.pi))
    assert.is_nil(is.number.znegative(""))
    assert.is_nil(is.number.znegative(' '))
    assert.is_nil(is.number.znegative('  '))
    assert.is_nil(is.number.znegative('	'))
    assert.is_nil(is.number.znegative('		'))
    assert.is_nil(is.number.znegative("	\r 	"))
    assert.is_nil(is.number.znegative("	\n 	"))
    assert.is_nil(is.number.znegative({}))
    assert.is_nil(is.number.znegative("false"))
    assert.is_nil(is.number.znegative("FALSE"))
  end)
  it("nil", function()
    assert.is_nil(is.number.znegative(nil))
    assert.is_nil(is.number.znegative())
  end)
end)