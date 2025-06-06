describe("number.integer", function()
  local number, integer
  setup(function()
    require 'meta'
    number = require 'meta.number'
    integer = number.integer
  end)
  it("meta", function()
    assert.callable(integer)
  end)
  it("integer", function()
    assert.equal(0, integer(0))
    for i=1,512 do
      assert.equal(i, integer(i))
      assert.equal(-i, integer(-i))
    end
    assert.equal(0, integer("0"))
    assert.equal(0, integer(false))
    assert.equal(1, integer(true))
  end)
  it("integer", function()
    assert.is_nil(integer(-math.pi))
    assert.is_nil(integer(math.pi))
    assert.is_nil(integer(1/2))
    assert.is_nil(integer(-(1/2)))
    assert.is_nil(integer(''))
    assert.is_nil(integer(' '))
    assert.is_nil(integer('  '))
    assert.is_nil(integer('	'))
    assert.is_nil(integer('		'))
    assert.is_nil(integer("	\r 	"))
    assert.is_nil(integer("	\n 	"))
    assert.is_nil(integer({}))
    assert.is_nil(integer("false"))
    assert.is_nil(integer("FALSE"))
  end)
  it("nil", function()
    assert.is_nil(integer(nil))
    assert.is_nil(integer())
  end)
end)