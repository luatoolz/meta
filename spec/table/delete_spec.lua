describe("table.delete", function()
  setup(function() require "meta" end)
  describe("test index", function()
    it("nil", function()
      assert.same({}, table.delete({}))
      assert.same({"x", "y", "z"}, table.delete({"x", "y", "z"}))
      assert.same({x=true}, table.delete({x=true}))
    end)
    it("positive number", function()
      assert.same({}, table.delete({"x"}, 1))
      assert.same({}, table.delete({"x"}, {1}))

      assert.same({"x"}, table.delete({"x"}, 2))

      assert.same({"x"}, table.delete({"x", "y"}, 2))
      assert.same({"y"}, table.delete({"x", "y"}, 1))
      assert.same({"x"}, table.delete({"x", "y"}, {2}))
      assert.same({"y"}, table.delete({"x", "y"}, {1}))

      assert.same({"x", "y"}, table.delete({"x", "y"}, 3))

      assert.same({"x", "y"}, table.delete({"x", "y", "z"}, 3))
      assert.same({"x", "y"}, table.delete({"x", "y", "z"}, {3}))

      assert.same({x=true}, table.delete({x=true}, 1))
      assert.same({x=true}, table.delete({x=true}, 2))

      assert.same({x=true}, table.delete({x=true, "x"}, 1))
      assert.same({x=true, "x"}, table.delete({x=true, "x"}, 2))
      assert.same({x=true, "x"}, table.delete({x=true, "x", "y"}, 2))
      assert.same({x=true, "y"}, table.delete({x=true, "x", "y"}, 1))
    end)
    it("negative number", function()
      assert.same({}, table.delete({"x"}, -1))
      assert.same({}, table.delete({"x"}, {-1}))

      assert.same({"x"}, table.delete({"x"}, -2))

      assert.same({"x"}, table.delete({"x", "y"}, -1))
      assert.same({"y"}, table.delete({"x", "y"}, -2))
      assert.same({"x"}, table.delete({"x", "y"}, {-1}))
      assert.same({"y"}, table.delete({"x", "y"}, {-2}))

      assert.same({"y", "z"}, table.delete({"x", "y", "z"}, -3))
      assert.same({"y", "z"}, table.delete({"x", "y", "z"}, {-3}))
      assert.same({"x", "z"}, table.delete({"x", "y", "z"}, -2))
      assert.same({"x", "z"}, table.delete({"x", "y", "z"}, {-2}))
      assert.same({"x", "y"}, table.delete({"x", "y", "z"}, -1))
      assert.same({"x", "y"}, table.delete({"x", "y", "z"}, {-1}))

      assert.same({x=true}, table.delete({x=true}, -1))
      assert.same({x=true}, table.delete({x=true}, -2))

      assert.same({x=true}, table.delete({x=true, "x"}, -1))
      assert.same({x=true, "x"}, table.delete({x=true, "x"}, -2))
      assert.same({x=true, "x"}, table.delete({x=true, "x", "y"}, -1))
      assert.same({x=true, "y"}, table.delete({x=true, "x", "y"}, -2))
    end)
    it("multi numbers", function()
      assert.same({"z"}, table.delete({"x", "y", "z"}, 2, 1))
      assert.same({"z"}, table.delete({"x", "y", "z"}, {2, 1}))
      assert.same({"z"}, table.delete({"x", "y", "z"}, {2}, 1))
      assert.same({"z"}, table.delete({"x", "y", "z"}, 2, {1}))

      assert.same({"y"}, table.delete({"x", "y", "z"}, -1, 1))

      assert.same({"y"}, table.delete({"x", "y", "z"}, 3, 1))
      assert.same({"y"}, table.delete({"x", "y", "z"}, {3, 1}))
      assert.same({"y"}, table.delete({"x", "y", "z"}, -1, 1))

      assert.same({x=true}, table.delete({x=true, "x"}, 1, 1))
      assert.same({x=true}, table.delete({x=true, "x"}, 1, 2))
      assert.same({x=true, "y"}, table.delete({x=true, "x", "y"}, 1, 2))
      assert.same({x=true}, table.delete({x=true, "x", "y"}, 2, 1))
      assert.same({x=true, "x"}, table.delete({x=true, "x", "y"}, 2, 2))

      assert.same({x=true}, table.delete({x=true, "x"}, -1, -1))
      assert.same({x=true}, table.delete({x=true, "x"}, -1, -2))
      assert.same({x=true}, table.delete({x=true, "x", "y"}, -1, -1))
      assert.same({x=true, "x"}, table.delete({x=true, "x", "y"}, -1, -2))
      assert.same({x=true}, table.delete({x=true, "x", "y"}, -2, -1))
      assert.same({x=true, "y"}, table.delete({x=true, "x", "y"}, -2, -2))
    end)
    it("key", function()
      assert.same({x=true}, table.delete({x=true}, 'y'))
      assert.same({x=true}, table.delete({x=true}, 'y', 'y'))

      assert.same({}, table.delete({x={}}, 'x'))
      assert.same({}, table.delete({x={}}, {'x'}))
      assert.same({}, table.delete({[true]={}}, true))
      assert.same({}, table.delete({[false]={}}, false))

      assert.same({}, table.delete({x=true}, 'x'))
      assert.same({}, table.delete({x=true}, 'x', 'x'))
      assert.same({}, table.delete({x=true}, {'x'}))
      assert.same({}, table.delete({x=true}, {'x', 'x'}))
      assert.same({}, table.delete({x=true}, 'x', 'y'))
      assert.same({}, table.delete({x=true}, {'x', 'y'}))
      assert.same({}, table.delete({x=true}, {'x'}, 'y'))
      assert.same({}, table.delete({x=true}, 'x', {'y'}))

      assert.same({"x", "y", "z"}, table.delete({"x", "y", "z"}, 'x'))
      assert.same({"x", "y", "z"}, table.delete({"x", "y", "z", x=true}, 'x'))
      assert.same({"x", "y", "z", x=true}, table.delete({"x", "y", "z", x=true}, 'y'))

      assert.same({}, table.delete({x={}}, 'x'))
      assert.same({}, table.delete({x={}}, {'x'}))
      assert.same({y={}}, table.delete({x={},y={}}, 'x'))
      assert.same({x={}}, table.delete({x={},y={}}, 'y'))
      assert.same({}, table.delete({x={},y={}}, 'x', 'y'))
    end)
    it("complex", function()
      assert.same({x={}}, table.delete({x={'x'}}, {x={1}}))
      assert.same({x={'x'}}, table.delete({x={'x'}}, {x={2}}))

      assert.same({x={}}, table.delete({x={y={}}}, {x={'y'}}))
      assert.same({x={y={}}}, table.delete({x={y={z={}}}}, {x={y={'z'}}}))

      assert.same({x={y={z={}}}}, table.delete({x={y={z={}}}}, {x={y={z={}}}}))
      assert.same({x={y={z={'b'}}}}, table.delete({x={y={z={'a','b'}}}}, {x={y={z={1}}}}))
      assert.same({x={y={z={'a'}}}}, table.delete({x={y={z={'a','b'}}}}, {x={y={z={2}}}}))
      assert.same({x={y={z={'a'}}}}, table.delete({x={y={z={'a','b'}}}}, {x={y={z={-1}}}}))
    end)
  end)
  it("__sub", function()
    assert.same(table {}, table {} - nil)
    assert.same(table {}, table {} - 1)

    assert.same(table {"y", 'z'}, table {"x", "y", "z"} - 1)
    assert.same(table {"x", "y"}, table {"x", "y", "a"} - 3)
    assert.same(table {"x", "y"}, table {"x", "y", "a"} - {3})

    assert.same(table {"x", "y"}, table {"x", "y", a="a"} - "a")
    assert.same(table {"x", "y"}, table {"x", "y", a="a"} - {"a"})

    assert.same(table {"x", "y"}, table {"x", "y", a={x={"a"},y={"b"},z={"c"}}} - {'a'})

    assert.same(table {"x", "y",a={y={"b"},z={"c"}}}, table {"x", "y", a={x={"a"},y={"b"},z={"c"}}} - {a={"x"}})
    assert.same(table {"x", "y",a={x={"a"},z={"c"}}}, table {"x", "y", a={x={"a"},y={"b"},z={"c"}}} - {a={"y"}})
    assert.same(table {"x", "y",a={x={"a"},y={"b"}}}, table {"x", "y", a={x={"a"},y={"b"},z={"c"}}} - {a={"z"}})

    assert.same(table {"x", "y",a={z={"c"}}}, table {"x", "y", a={x={"a"},y={"b"},z={"c"}}} - {a={"x","y"}})

    assert.same(table {"x", "y",a={x={"a"},y={"b"},z={"c"}}}, table {"x", "y", a={x={"a"},y={"b"},z={"c"}}} - {a={}})
  end)
end)