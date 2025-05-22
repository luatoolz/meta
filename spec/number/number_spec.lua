describe("number", function()
  local number
  setup(function()
    require 'meta'
    number = require 'meta.number'
  end)
  it("positive", function()
    assert.equal(0, number(0))
    assert.equal(0, number('0'))

    assert.equal(10, number('a', 16))
    assert.equal(10, number('12', 8))

    assert.equal(12, number(12))

    assert.equal(1, number(true))
    assert.equal(0, number(false))

    assert.equal(1, number({true}))
    assert.equal(2, number({true,false}))
    assert.equal(1, number({1}))
    assert.equal(2, number({1,2}))
    assert.equal(3, number({1,2,3}))
    assert.equal(4, number({1,2,3,4}))

    local arr=function(x) return setmetatable(x,{
      __tonumber=function(self) return #self+1 end
    }) end

    assert.equal(2, number(arr({true})))
    assert.equal(3, number(arr({true,false})))
    assert.equal(2, number(arr({1})))
    assert.equal(3, number(arr({1,2})))
    assert.equal(4, number(arr({1,2,3})))
    assert.equal(5, number(arr({1,2,3,4})))
  end)
  it("negative", function()
    local arrempty=function(x) return setmetatable(x,{}) end
    assert.is_nil(number(arrempty({})))
    assert.is_nil(number(arrempty({x=true})))
    assert.is_nil(number(arrempty({x=true,y=1})))

    assert.is_nil(number({}))
    assert.is_nil(number({x=true}))
    assert.is_nil(number({x=true,y=1}))
    assert.is_nil(number(''))
    assert.is_nil(number('ui'))
  end)
  it("nil", function()
    assert.is_nil(number(nil))
    assert.is_nil(number())
  end)
end)