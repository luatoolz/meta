local loader=assert(require "meta.loader")
return loader('testdata.files')*function(...) return ... end