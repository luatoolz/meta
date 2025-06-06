describe("number.zpositive", function()
  local number, zpositive
  setup(function()
    require 'meta'
    number = require 'meta.number'
    zpositive = number.zpositive
  end)
  it("meta", function()
    assert.callable(zpositive)
  end)
  it("zpositive", function()
    for i=0,512 do
      assert.equal(i, zpositive(i))
    end
    assert.equal(1, zpositive(true))
    assert.equal(0, zpositive(false))
    assert.equal(0, zpositive("0"))
    assert.equal(1, zpositive("1"))
    assert.equal(12, zpositive('12'))
    assert.equal(77, zpositive('77'))
  end)
  it("zpositive", function()
    assert.is_nil(zpositive(-math.pi))
    assert.is_nil(zpositive(-1))
    assert.is_nil(zpositive(""))
    assert.is_nil(zpositive(' '))
    assert.is_nil(zpositive('  '))
    assert.is_nil(zpositive('	'))
    assert.is_nil(zpositive('		'))
    assert.is_nil(zpositive("	\r 	"))
    assert.is_nil(zpositive("	\n 	"))
    assert.is_nil(zpositive({}))
    assert.is_nil(zpositive('false'))
    assert.is_nil(zpositive("FALSE"))
  end)
  it("nil", function()
    assert.is_nil(zpositive(nil))
    assert.is_nil(zpositive())
  end)
end)