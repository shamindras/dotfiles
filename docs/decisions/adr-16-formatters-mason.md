---
id: adr-16-formatters-mason
type: adr
date: 2026-11-11
status: accepted
supersedes: none
---

# Mason owns the formatters and linters nvim uses

Mason (nvim's `mason-tool-installer` list) installs every formatter and linter nvim uses. Homebrew keeps a copy only
when a repo script, just recipe or CI job calls the tool: prettier (`just prettier_md`, `manifest_set`), shellcheck
(`just test_static`) and stylua (`just stylua_config`), plus the general CLIs jq and yq. Those five therefore have two
copies; jsonlint, shfmt, taplo and yamllint leave the Homebrew manifest (removing them from the manifest uninstalls
nothing), and markdownlint-cli2 and ruff stay Mason-only. eslint_d is dropped entirely: nothing in the repo or nvim
calls it. Refines [Homebrew is the only package manager](adr-04-engine.md) for nvim's tools.
