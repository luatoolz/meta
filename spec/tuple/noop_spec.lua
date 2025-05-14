describe("tuple.noop", function()
  local noop
  setup(function()
    noop = require('meta.tuple').noop
  end)
  it("scope", function()
    assert.equal(7, noop(7))
    assert.equal("xyz", table.concat({noop("x", "y", "z")}))
    assert.same({"x", "y", "z"}, {noop("x", "y", "z")})
    local a,b,c = noop(1,2,3)
    assert.same({1,2,3}, {a,b,c})
  end)
end)