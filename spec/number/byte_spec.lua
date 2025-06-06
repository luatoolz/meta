describe("number.byte", function()
  local number, byte
  setup(function()
    require 'meta'
    number = require 'meta.number'
    byte = number.byte
  end)
  it("meta", function()
    assert.callable(byte)
  end)
  it("positive", function()
    for i=0,255 do
      assert.equal(i, byte(i))
    end
    assert.equal(0, byte(false))
    assert.equal(1, byte(true))
    assert.equal(0, byte('0'))
  end)
  it("negative", function()
    assert.is_nil(byte(math.pi))
    assert.is_nil(byte(-1))
    assert.is_nil(byte(256))
    assert.is_nil(byte(""))
    assert.is_nil(byte(' '))
    assert.is_nil(byte('  '))
    assert.is_nil(byte('	'))
    assert.is_nil(byte('		'))
    assert.is_nil(byte("	\r 	"))
    assert.is_nil(byte("	\n 	"))
    assert.is_nil(byte({}))
    assert.is_nil(byte("false"))
    assert.is_nil(byte("FALSE"))
  end)
  it("nil", function()
    assert.is_nil(byte(nil))
    assert.is_nil(byte())
  end)
end)