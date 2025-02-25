require 'meta.table'
local pkgdir = require 'meta.module.pkgdir'
return ((table() .. package.path:gmatch('[^;]*')) .. package.cpath:gmatch('[^;]*')) * pkgdir