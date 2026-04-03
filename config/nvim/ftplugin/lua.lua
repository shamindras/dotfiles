-- Buffer-local settings for Lua files
-- Enforce marker-based folding (overrides any runtime/default that sets expr)

-- {{{ Fold Settings

-- Guard: skip if large file detection already switched to manual
if not vim.b.large_file then
  vim.wo.foldmethod = 'marker'
  vim.wo.foldlevel = 99 -- Folds exist but start open (auto-collapse handles UX)
end

-- }}}
