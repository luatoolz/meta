describe('call', function()
  local meta, call
  local error_function, success_function
  local strip_traceback_header, cut_traceback_after
  setup(function()
    meta = require "meta"
    call = meta.call
    error_function = function() error("EEK") end
    success_function = function() return 'ok' end
    strip_traceback_header = function(traceback)
      return traceback:gsub("^.-\n", "")
    end
    cut_traceback_after = function(traceback, name)
      local pos = traceback:find(name, 0, true)
      if not pos then return traceback end
      pos = traceback:find("\n", pos, true)
      if not pos then return traceback end
      return traceback:sub(1, pos)
    end
  end)
  teardown(function()
    call.protect = true
    call.report = false
  end)
  describe("test vars", function()
    it("noreport", function()
      assert.callable(call.noreport)
      assert.has_error(function() call.noreport=true end)
    end)
    it("protect", function()
      call.protect = true
      assert.is_true(call.protect)
      call.protect = false
      assert.is_nil(call.protect)
      call.protect = true
      assert.is_true(call.protect)
      call.protect = false
      assert.is_nil(call.protect)
      call.protect = true
      assert.is_true(call.protect)
    end)
    it("report", function()
      local noreport = call.noreport
      call.report = true
      assert.is_true(call.report)
      assert.callable(call.handler)
      assert.not_equal(call.noreport, call.handler)
      assert.equal(noreport, call.noreport)
      call.report = false
      assert.is_nil(call.report)
      assert.equal(call.noreport, call.handler)
      assert.equal(noreport, call.noreport)
      call.report = true
      assert.is_true(call.report)
      assert.callable(call.handler)
      assert.not_equal(call.noreport, call.handler)
      assert.equal(noreport, call.noreport)
      call.report = false
      assert.is_nil(call.report)
      assert.equal(call.noreport, call.handler)
      assert.equal(noreport, call.noreport)
      call.report = true
      assert.is_true(call.report)
      assert.callable(call.handler)
      assert.not_equal(call.noreport, call.handler)
      assert.equal(noreport, call.noreport)
      call.report = nil
      assert.is_nil(call.report)
      assert.equal(call.noreport, call.handler)
      assert.equal(noreport, call.noreport)
      call.report = true
      assert.is_true(call.report)
      assert.callable(call.handler)
      assert.not_equal(call.noreport, call.handler)
      assert.equal(noreport, call.noreport)
      call.report = nil
      assert.is_nil(call.report)
      assert.equal(call.noreport, call.handler)
      assert.equal(noreport, call.noreport)

      call.report = print
      assert.is_true(call.report)
      assert.callable(call.handler)
      assert.equal(noreport, call.noreport)
      call.report = nil
      assert.is_nil(call.report)
      assert.equal(noreport, call.noreport)
    end)
  end)
  it("call", function()
    local assert_call = function() return assert(nil, 'error') end
    assert.has_error(assert_call)
    assert.no_error(function() return call.pcall(assert_call) end)
    assert.no_error(function() return call(assert_call) end)
    assert.no_error(call.pcaller(assert_call))
    assert.no_error(call.caller(assert_call))

    local okf = function(x) return x end
    assert.no_error(function() return okf(true) end)
    local ok = call.caller(okf)
    assert.is_true(ok(true))
    assert.is_false(ok(false))
    assert.is_nil(ok())
    assert.is_nil(ok(nil))
  end)
  it("can create normal tracebacks without coroutines", function()
    local function testf()
      local real_traceback, call_traceback = debug.traceback(), call.traceback()
      return real_traceback, call_traceback
    end

    local function FUNCTION_BOUNDARY()
      local a, b = testf()
      return a, b
    end

    local real_traceback, call_traceback = FUNCTION_BOUNDARY()
    real_traceback = cut_traceback_after(real_traceback, "FUNCTION_BOUNDARY")
    call_traceback = cut_traceback_after(call_traceback, "FUNCTION_BOUNDARY")

    assert.are.same(real_traceback, call_traceback)
  end)
  describe("can \"stitch\" tracebacks across coroutine boundaries", function()
    local co = coroutine.create(error_function)
    coroutine.resume(co)

    local function testf()
      local real_traceback, call_traceback = debug.traceback(), call.traceback(co)
      return real_traceback, call_traceback
    end

    local function FUNCTION_BOUNDARY()
      local a, b = testf()
      return a, b
    end

    local real_traceback, call_traceback = FUNCTION_BOUNDARY()
    local co1_traceback = debug.traceback(co)
    real_traceback = cut_traceback_after(real_traceback, "FUNCTION_BOUNDARY")
    call_traceback = cut_traceback_after(call_traceback, "FUNCTION_BOUNDARY")

    it("contains the coroutine's traceback", function()
      assert.is_not_nil(call_traceback:find(co1_traceback, 0, true))
    end)

    it("contains the calling coroutine's traceback", function()
      local stripped = strip_traceback_header(real_traceback)
      assert.is_not_nil(call_traceback:find(stripped, 0, true))
    end)
  end)
  it("has call.presume", function()
    local co = coroutine.create(error_function)
    local status, r = call.presume(co)

    assert.is_false(status)
    assert.is_not_nil(r:find("EEK", 0, true))

    co = coroutine.create(success_function)
    status, r = call.presume(co)

    assert.is_true(status)
    assert.equal('ok', r)
  end)
  it("has call.xpresume", function()
    local co, msg
    local function handler(m, coro)
      assert.equal(co, coro)
      msg = m
      return handler
    end

    co = coroutine.create(error_function)
    local r, e = call.xpresume(co, handler)

    assert.is_nil(r)
    assert.equal(handler, e)
    assert.is_not_nil(msg:find("EEK", 0, true))

    co = coroutine.create(success_function)
    r, e = call.xpresume(co, handler)

    assert.equal('ok', r)
    assert.is_nil(e)

    assert.equal('dead', call.status(co))

    r, e = call.xpresume(co, handler)
    assert.is_nil(r)
    assert.is_string(e)
    assert.is_not_nil(e:find("coroutine is dead", 0, true))
  end)
  it("has call.resume", function()
    local co
    local function resumer()
      return call.resume(co)
    end

    co = coroutine.create(error_function)
    local r, e = call.resume(co)

    assert.is_nil(r)
    assert.is_not_nil(e:find("EEK", 0, true))
    assert.is_not_nil(e:find("Coroutine failure", 0, true))
    assert.is_not_nil(e:find("Coroutine stack traceback", 0, true))

    co = coroutine.create(success_function)
    r, e = assert.has_no_errors(resumer)

    assert.equal('ok', r)
    assert.is_nil(e)
  end)
  it("has an extended call.wrap", function()
    local co = call.wrap(error_function)
    local r, e = co()

    assert.is_nil(r)
    assert.is_not_nil(e:find("EEK", 0, true))
    assert.is_not_nil(e:find("Coroutine failure", 0, true))
    assert.is_not_nil(e:find("Coroutine stack traceback", 0, true))

    assert.equal('dead', call.status(co))

    r, e = co()
    assert.is_nil(r)
    assert.is_not_nil(e:find("coroutine is dead", 0, true))
    assert.is_not_nil(e:find("Function failure", 0, true))
    assert.is_not_nil(e:find("Function stack traceback", 0, true))

    co = call.wrap(success_function)
    r, e = assert.has_no_errors(co)

    assert.equal('ok', r)
    assert.is_nil(e)
  end)
  it("call.co", function()
    assert.is_thread(call.co(call.create(error_function)))
    assert.is_thread(call.co(call.wrap(error_function)))
    assert.is_nil(call.co(error_function))
  end)
  it("call.status", function()
    local co = call.create(error_function)
    assert.is_nil(call.status())
    assert.is_nil(call.status(nil))
    assert.is_nil(call.status({}))
    assert.is_nil(call.status('co'))
    assert.is_nil(call.status('any'))
    assert.is_nil(call.status(true))
    assert.is_nil(call.status(false))
    assert.is_nil(call.status(string.lower))
    assert.equal('suspended', call.status(co))
    assert.equal('suspended', call.status(call.wrap(error_function)))
  end)
  it("call.wrap", function()
    local co = call.wrap(function()
      call.yield(1)
      call.yield(2)
      call.yield(3)
    end)
    local rv = {}
    for v in co do table.insert(rv, v) end
    assert.same({1,2,3}, rv)
  end)
end)