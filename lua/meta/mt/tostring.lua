local mt = require 'meta.gmt'
require 'meta.string'
return function(self) return (mt(self).__sep or string.sep):join(self[0], self) or '' end