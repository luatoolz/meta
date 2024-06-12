local module = require "meta.module"
return module(select(1, ...)).recursive.preload
