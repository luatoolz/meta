local _ = require '_'
print(_)

local a = require '-'
print(a)

local b = require '~'
print(b)

local c = require '  '
print(c)

local sibling = require 'sibling'
print(sibling)

return {
  _=_,
  ['-']=a,
  ['~']=b,
  ['  ']=c,
  sibling=sibling,
}