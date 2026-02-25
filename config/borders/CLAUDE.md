# JankyBorders Configuration

## Overview

JankyBorders adds configurable window borders to macOS. It runs as a
background brew service and reads its config from `bordersrc` on startup.

Docs: https://github.com/FelixKratz/JankyBorders
Installed version: borders-v1.8.4 (verified 2026-02-25)

## Config File Structure

- `bordersrc` — Bash script sourced by the `borders` service on start.
  Builds an options array and passes it to the `borders` command.

## Valid Options Reference

| Option           | Values / Example              | Description                       |
| ---------------- | ----------------------------- | --------------------------------- |
| `style`          | `round`, `square`             | Border corner style               |
| `width`          | `1.0` .. `10.0`               | Border thickness in points        |
| `hidpi`          | `on`, `off`                   | HiDPI (Retina) scaling            |
| `active_color`   | `0xAARRGGBB` (hex)            | Border color for focused window   |
| `inactive_color` | `0xAARRGGBB` (hex)            | Border color for unfocused windows|
| `background_color`| `0xAARRGGBB` (hex)           | Background fill color             |
| `ax_focus`       | `on`, `off`                   | Use accessibility API for focus   |
| `blacklist`      | comma-separated bundle IDs    | Apps to exclude from borders      |
| `whitelist`      | comma-separated bundle IDs    | Apps to include (exclusive mode)  |

## Development Notes

- Config changes require a service restart: `brew services restart borders`
- An nvim autocmd in `config/nvim/lua/shamindras/core/autocmds.lua`
  auto-restarts the service on save of `bordersrc`.
- To stop borders: `brew services stop borders`
- To check status: `brew services list | grep borders`
