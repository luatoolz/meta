describe("to.number", function()
  local meta, to
  setup(function()
    meta = require "meta"
    to = meta.to
  end)
  it("positive", function()
    assert.equal(0, to.number(0))
    assert.equal(0, to.number('0'))

    assert.equal(10, to.number('a', 16))
    assert.equal(10, to.number('12', 8))

    assert.equal(12, to.number(12))
    assert.equal(12, to.number(12, 8))

    assert.equal(1, to.number({true}))
    assert.equal(2, to.number({true,false}))
    assert.equal(1, to.number({1}))
    assert.equal(2, to.number({1,2}))
    assert.equal(3, to.number({1,2,3}))
    assert.equal(4, to.number({1,2,3,4}))

    local arr=function(x) return setmetatable(x,{
      __tonumber=function(self) return #self+1 end
    }) end
    local arrlen=function(x) return setmetatable({_=x},{
      __len=function(self) return #(self._ or {})+2 end
    }) end

    assert.equal(2, to.number(arr({true})))
    assert.equal(3, to.number(arr({true,false})))
    assert.equal(2, to.number(arr({1})))
    assert.equal(3, to.number(arr({1,2})))
    assert.equal(4, to.number(arr({1,2,3})))
    assert.equal(5, to.number(arr({1,2,3,4})))

    assert.equal(3, to.number(arrlen({true})))
    assert.equal(4, to.number(arrlen({true,false})))
    assert.equal(3, to.number(arrlen({1})))
    assert.equal(4, to.number(arrlen({1,2})))
    assert.equal(5, to.number(arrlen({1,2,3})))
    assert.equal(6, to.number(arrlen({1,2,3,4})))
  end)
  it("negative", function()
    local arrempty=function(x) return setmetatable(x,{}) end
    assert.is_nil(to.number(arrempty({})))
    assert.is_nil(to.number(arrempty({x=true})))
    assert.is_nil(to.number(arrempty({x=true,y=1})))

    assert.is_nil(to.number({}))
    assert.is_nil(to.number({x=true}))
    assert.is_nil(to.number({x=true,y=1}))
    assert.is_nil(to.number(''))
    assert.is_nil(to.number('ui'))
  end)
  it("nil", function()
    assert.is_nil(to.number(nil))
    assert.is_nil(to.number())
  end)
end)