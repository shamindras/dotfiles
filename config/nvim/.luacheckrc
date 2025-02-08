-- .luacheckrc
-- Rerun tests only if their modification time changed.
cache = true

-- Global objects defined by the C code
read_globals = {
    -- Neovim globals
    "vim",
    
    -- Builtins
    "debug",
    "jit",
    "os",
    "assert",
    "collectgarbage",
    "error",
    "getfenv",
    "getmetatable",
    "ipairs",
    "load",
    "loadfile",
    "loadstring",
    "next",
    "pairs",
    "pcall",
    "print",
    "rawequal",
    "rawget",
    "rawset",
    "select",
    "setfenv",
    "setmetatable",
    "tonumber",
    "tostring",
    "type",
    "unpack",
    "xpcall",
    "coroutine",
    "string",
    "table",
    "math",
    "io",
    "package",
}

-- Global objects that can be modified
globals = {
    -- Test-related globals
    "describe",
    "it",
    "before_each",
    "after_each",
    "teardown",
    "pending",
    "assert",
}

-- Redef warnings are turned off since we may have multiple files defining the same objects
redefined = false

-- Don't report unused self arguments of methods.
self = false

-- Warnings to ignore
ignore = {
    -- Ignore warnings about unused variables with _ prefix
    "212/_.*",
    -- Ignore warnings about unused arguments
    "212",
    -- Ignore warnings about line length
    "631",
}

-- Options for specific files/directories
files["spec"] = {
    std = "+busted",
}

-- Maximum line length
max_line_length = 120

-- Maximum cyclomatic complexity of functions
max_cyclomatic_complexity = 20

-- Allow shadowing of globals and locals
allow_defined = true
allow_defined_top = true

-- Settings for code patterns
codes = true

-- Run in parallel when possible
jobs = 4

-- Additional custom rules
useless_type_check = true
variable_clash = true
