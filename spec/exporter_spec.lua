describe("exporter", function()
  local t, export, array, add, clear, tex
  setup(function()
    t = require "meta"
    export = t.exporter
    array = t.array
    tex = export
    add = function(x) return export(x, true) end
    clear = function(x) return export(x, false) end
  end)
  it("atom", function()
    assert.equal(0, export(0))
    assert.equal(77, export(77))
    assert.equal('', export(''))
    assert.equal('x', export('x'))
    assert.equal('{}', export('{}'))
    assert.equal(true, export(true))
    assert.equal(false, export(false))
    assert.equal(nil, export(nil))
    assert.equal(nil, export())

    assert.same({}, export({}))
  end)
  it("add+clear", function()
    local values={{},{1},{1,2},{1,2,3},{a=true},{a=true,b=77},{a='x'},{a=1,b=8}}
    for _,v in ipairs(values) do
      assert.same(v, clear(add(v)))
    end
  end)
  it("export array", function()
--    local tex=export
    assert.same({}, tex(array()))
    assert.same({}, tex(array({})))
    assert.same({'a'}, tex(array('a')))
    assert.same({'a', 'b', 'c', 'd'}, tex(array('a', 'b', 'c', 'd')))
    assert.same({1,2,3,4}, tex(array(1,2,3,4)))

    assert.same({}, tex(tex(array())))
    assert.same({}, tex(tex(array({}))))
    assert.same({'a'}, tex(tex(array('a'))))
    assert.same({'a', 'b', 'c', 'd'}, tex(tex(array('a', 'b', 'c', 'd'))))
    assert.same({1,2,3,4}, tex(tex(array(1,2,3,4))))

    assert.same({}, add(array()))
    assert.same({}, add(array({})))
    assert.same({'a', __array=true}, add(array('a')))
    assert.same({'a', 'b', 'c', 'd', __array=true}, add(array('a', 'b', 'c', 'd')))
    assert.same({1,2,3,4, __array=true}, add(array(1,2,3,4)))

    assert.same({}, add(add(array())))
    assert.same({}, add(add(array({}))))
    assert.same({'a', __array=true}, add(add(array('a'))))
    assert.same({'a', 'b', 'c', 'd', __array=true}, add(add(array('a', 'b', 'c', 'd'))))
    assert.same({1,2,3,4,__array=true}, add(add(array(1,2,3,4))))
  end)
end)
