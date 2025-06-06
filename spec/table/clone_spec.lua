describe('table.clone', function()
  local clone, o, __index, __indexg, r, g, a, b, c, d, e
  setup(function()
    require 'meta.table'
    clone = table.clone
    __index = function(self, k) return rawget(self, k) end
    __indexg = function(self, k) return rawget(self, k) or (getmetatable(self) or {})[k] end
    a, b = {some="a"}, {some="b"}
  end)
  before_each(
      function() r, o = nil, setmetatable({yes="yes"}, {__call=function(self, ...) end, __div=function(self, ...) end, test=function(self, ...) end}) end)
  it("common", function()
    assert.is_function(clone)
    assert.equal('yes', o.yes)
    assert.is_function(getmetatable(o).test)
    assert.is_function(rawget(getmetatable(o), 'test'))
  end)
  it("noindex", function()
    r = clone(o)
    g = getmetatable(r)
    assert.is_table(r)
    assert.is_table(g)
    assert.is_nil(getmetatable(g))
    assert.equal('yes', r.yes)
    assert.is_function(g.__call)
    assert.is_nil(g.__index)
    assert.is_function(g.__div)
    assert.is_function(g.test)
    assert.is_nil(r.test)
  end)
  it("noindex + __index table", function()
    r = clone(o, {__index=a})
    g = getmetatable(r)
    assert.is_table(r)
    assert.is_table(g)
    assert.is_nil(getmetatable(g))
    assert.equal('yes', r.yes)
    assert.is_function(rawget(g, '__call'))
    assert.is_table(rawget(g, '__index'))
    assert.equal("a", rawget(rawget(g, '__index'), 'some'))
    assert.equal("a", r.some)
    assert.is_function(rawget(g, '__div'))
    assert.is_function(rawget(g, 'test'))
    assert.equal('nil', type(r.test))
  end)
  it("noindex + __index function", function()
    r = clone(o, {__index=__index})
    g = getmetatable(r)
    assert.is_table(r)
    assert.is_table(g)
    assert.is_nil(getmetatable(g))
    assert.is_function(g.__call)
    assert.is_function(rawget(g, '__call'))
    assert.is_function(g.__index)
    assert.is_function(g.__div)
    assert.is_nil(r.test)
  end)
  it("index", function()
    getmetatable(o).__index = a
    assert.equal('yes', o.yes)
    r = clone(o)
    g = getmetatable(r)
    assert.is_table(r)
    assert.is_table(g)
    assert.is_nil(getmetatable(g))
    assert.equal('yes', r.yes)
    assert.is_function(rawget(g, '__call'))
    assert.is_table(rawget(g, '__index'))
    assert.equal("a", rawget(rawget(g, '__index'), 'some'))
    assert.equal("a", r.some)
    assert.is_function(rawget(g, '__div'))
    assert.is_function(rawget(g, 'test'))
    assert.is_nil(r.test)
  end)
  it("index + __index table", function()
    getmetatable(o).__index = a
    r = clone(o, {__index=b})
    g = getmetatable(r)
    assert.is_table(r)
    assert.is_table(g)
    assert.is_nil(getmetatable(g))
    assert.equal('yes', r.yes)
    assert.is_function(rawget(g, '__call'))
    assert.is_table(rawget(g, '__index'))
    assert.equal("b", rawget(rawget(g, '__index'), 'some'))
    assert.equal("b", r.some)
    assert.is_function(rawget(g, '__div'))
    assert.is_function(rawget(g, 'test'))
    assert.is_nil(r.test)
  end)
  it("index + __index func", function()
    getmetatable(o).__index = a
    r = clone(o, {__index=__indexg})
    g = getmetatable(r)
    assert.is_table(r)
    assert.is_table(g)
    assert.is_nil(getmetatable(g))
    assert.equal('yes', r.yes)
    assert.is_function(rawget(g, '__call'))
    assert.is_function(g.__index)
    assert.is_nil(r.some)
    assert.is_function(g.__div)
    assert.is_function(r.__div)
    assert.equal(getmetatable(o).test, r.test)
  end)
  it("index + __index table", function()
    getmetatable(o).__index = a
    c = {c="c", __index=b}
    d = {d="d", __index=c}
    e = {e="e", __index=d}
    local new = {__index=e}
    r = clone(o, {__index=e})
    g = getmetatable(r)
    assert.is_table(r)
    assert.is_table(g)
    assert.is_nil(getmetatable(g))
    assert.equal('yes', r.yes)
    assert.is_function(g.__call)
    assert.is_table(g.__index)
    assert.same(new.__index, g.__index)
    assert.equal("b", r.some)
    assert.is_function(rawget(g, '__div'))
    assert.equal(getmetatable(o).test, rawget(g, 'test'))
    assert.is_nil(r.test)
    assert.equal("b", r.some)
    assert.equal("c", r.c)
    assert.equal("d", r.d)
    assert.equal("e", r.e)
  end)
end)