# meta.call
This module is an integration of 3 parts: calling, parallelizing, error handling.
- coroutine xpcall/pcall, co.wrap, coro utils, co.pool
- regular call xpcall/pcall, result and error dispatching
- error/log handling, traceback/tostringer, config

`meta.iter` with map/filter actions are actively rely on this module.

## error-relating functions
- `call.traceback`: traceback formatter
- `call.tostring`: objects tostringer
- `call.errors`: varargs formatter
- `call.error`: run/return error
- `call.assert`: assert
- `call.log`: log message

## call-/co- dispatching related
- `call.pcaller`: pcalled caller returning only actual execution return results
- `call.xpcall`:  core xpcall impl
- `call.pcall`:  xpcall-based pcall
- `call.xpdispatch`: result/error xp-dispatcher
- `call.dispatch`: result/error dispatcher
- `call.xpresume`: coro xp-resumer
- `call.resume`: coro resumer
- `call.resumeok`: coro resume for valid-only args
- `call.yieldok`: yield only good results
- `call.yieldokr`: recursive good-only yield processor

## co- utils
- `call.wrap2`: co.wrapper returning both runner-iterator and coro
- `call.wrap`: co.wrapper returning runner-iterator
- `call.co`: get coro from runner
- `call.status`: get coro status
- `call.alive`: test coro is alive
- `call.run`: thread runner
- `call.pool`: producer/consumer runner

## config
- `call.printer`: output function (default print, could be set to ngx.LOG/syslogger etc)
- `call.threads`: #threads for co.pool
- `call.protect`: switch protect on/off (on)
- `call.report`: switch report errors on/off (on)
- `call.handler`: xpcall/pcall error handler
