describe("table.select", function()
  local sel, pack
  setup(function()
    require 'compat53'
    sel = require "meta.table.select"
    pack = function(...) local rv=table.pack(...); rv.n=nil; return rv end
  end)
  it("sel", function()
    assert.equal(true, select(2, sel({a=true}, {'a'})))

    assert.same({{a=true}, true}, pack(sel({a=true}, {'a'})))
    assert.same({{a=true, b=true}, true, true}, pack(sel({a=true, b=true}, {'a', 'b'})))


    assert.same({{a='A'}, 'A'}, pack(sel({a='A'}, {'a'})))
    assert.same({{a='A'}, 'A'}, pack(sel({a='A',x='y'}, {'a'})))

    assert.same({{a='A', b='B'}, 'A','B'}, pack(sel({a='A',b='B',x='y'}, {'a','b'})))
    assert.same({{a='A', b='B', c='C'}, 'A','B','C'}, pack(sel({a='A',b='B',c='C',x='y'}, {'a','b','c'})))

    assert.same({{a='A', b='B'}, 'A','B',nil}, pack(sel({a='A',b='B',cc='C',x='y'}, {'a','b','c'})))
    assert.same({{a='A', c='C'}, 'A',nil,'C'}, pack(sel({a='A',bb='B',c='C',x='y'}, {'a','b','c'})))
    assert.same({{b='B', c='C'}, nil,'B','C'}, pack(sel({aa='A',b='B',c='C',x='y'}, {'a','b','c'})))

    assert.same({a='A', b='B', c='C'}, select(1, sel({a='A',b='B',c='C',x='y'}, {'a','b','c'})))
    assert.equal('A', select(2, sel({a='A',b='B',c='C',x='y'}, {'a','b','c'})))
    assert.equal('B', select(3, sel({a='A',b='B',c='C',x='y'}, {'a','b','c'})))
    assert.equal('C', select(4, sel({a='A',b='B',c='C',x='y'}, {'a','b','c'})))

    assert.is_nil(select(2, sel({a='A',b='B',c='C',x='y'}, {'aa','b','c'})))
    assert.is_nil(select(3, sel({a='A',b='B',c='C',x='y'}, {'a','bb','c'})))
    assert.is_nil(select(4, sel({a='A',b='B',c='C',x='y'}, {'a','b','cc'})))
  end)
  it("negative", function()
    assert.is_nil(sel({}))
    assert.is_nil(sel({},{}))
    assert.is_nil(sel(''))
    assert.is_nil(sel(0))
    assert.is_nil(sel(1))
    assert.is_nil(sel(false))
    assert.is_nil(sel(true))
  end)
  it("nil", function()
    assert.is_nil(sel())
    assert.is_nil(sel(nil))
    assert.is_nil(sel(nil, nil))
    assert.is_nil(sel(nil, nil, nil))
    assert.is_nil(sel({}, nil, nil))
    assert.is_nil(sel({}, {}, nil))
    assert.is_nil(sel(nil, {}, nil))
    assert.is_nil(sel(nil, {}, {}))
    assert.is_nil(sel(nil, nil, {}))
  end)
end)