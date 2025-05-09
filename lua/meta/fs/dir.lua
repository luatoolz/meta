require 'meta.table'
local lfs   = require 'lfs'
local co    = require 'meta.call'
local iter  = require 'meta.iter'
local checker= require 'meta.checker'
local op    = require 'meta.op'
local meta  = require 'meta.lazy'
local fn    = meta({'fn'})
local path  = require 'meta.fs.path'
local fs    = require 'meta.fs'
local g     = getmetatable(path) or {}
local is    = {
  string  = function(x) return type(x)=='string' or nil end,
  like    = require 'meta.is.like',
  fs = {
  nondots = require 'meta.is.fs.nondots',
}}
_ = op
local predicate = checker({
  string       = function(self) return function(x) return (x or {})[self] end end,
  ['function'] = function(self) return self end,
}, type)
return setmetatable({},{
__computable= setmetatable({
  ls        = function(self) return self.isdir and iter(co.wrap(function()
                for n in lfs.dir(self.rpath) do co.yieldok(n) end end))%is.fs.nondots*function(v) return self..v end or fn.null end,
  lsr       = function(self) return self.isdir and iter(co.wrap(function() for a in self.ls do if a.isdir then
                for b in a.lsr do co.yieldok(b) end end; co.yieldok(a); end end)) or fn.null end,

  tree      = function(self) return self.isdir and iter(co.pool(self.lsr, function(prod) for a in prod do co.yieldok(a) end end)) or fn.null end,
  rmtree    = function(self) iter.each(self.tree%'nondir'*'rm'); iter.each(self.tree*'rmdir'); return self.rmdir end,
  mkdir     = function(self) return self.isdir or lfs.mkdir(tostring(self)) end,
  rmdir     = function(self) return (not self.exists) or (self.isdir and lfs.rmdir(self.rpath)) or nil end,
  mkdirp    = function(self) local ex, tail, ok, e = fs.isdir('.') and (self..'') or self.abs, {}
    while (not ex.isdir) and #ex>1 do table.insert(tail, table.remove(ex)) end
    repeat table.insert(ex, table.remove(tail)) if not ex.isdir then ok, e=lfs.mkdir(tostring(ex)) end; until #tail<=0 or e
    return ok, e end,
}, {__index=fs}),
__add       = g.__add,
__call      = g.__call,
__concat    = g.__concat,
__eq        = g.__tostring,
__index     = g.__index,
__tostring  = g.__tostring,
__id        = g.__id,
__sep       = g.__sep,
__name      = 'fs.dir',
--__iter      = function(self, it) return iter(self.ls, it) end,
__div       = function(self, apred) if self and apred then
  local pred=predicate(apred)
--  pred=op.div(pred)
  local nondots, el, ok = is.fs.nondots
  local _, dir_obj = lfs.dir(tostring(self))
  repeat el=dir_obj:next()
    if el and nondots(el) then ok=self..el else ok=nil end
  until pred(ok) or not el
  dir_obj:close()
  return ok
end end,
--__mul       = table.map,
--__mod       = table.filter,
__le        = g.__le,
__lt        = g.__lt,
__unm       = function(self) return (not self.exists) or self.rmtree end,
})