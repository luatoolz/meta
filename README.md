# lua meta methods library
- `loader`: dynamic loader, supports dotted module names, recursion without init.lua in dirs (nice for automatic using large automatic modules hierarchy)
- `preloader`: preloading wrapper for loader, supports module iterating by submodules (useful for seamless module handling without register-like routines)
- `memoize`: memoize front, supports function / closure / mt.__call
- `prequire`: pcall require
- `computed`: like js computed object, effective for data structures fast defining
- `chain`: chain multiple modules, useful for typed hierarchy combined with multiple objects definitions

