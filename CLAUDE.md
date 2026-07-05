# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A second, Lua-only Neovim configuration, built alongside the primary VimScript+CoC build at
`/home/serii/Documents/Apps/nvim` (symlinked to `~/.config/nvim`). This build uses **lazy.nvim**
as the plugin manager and **native LSP** (`nvim-lspconfig` + `mason.nvim`) instead of CoC.

It runs under a separate Neovim profile so both builds coexist without conflict:

```bash
NVIM_APPNAME=nvim-lua nvim
```

An `nvim-lua` shell alias for this is defined in `~/dotfiles/zsh_modules/zsh_aliases`.
`~/.config/nvim-lua` is a symlink to this repo; data/state/cache live under
`~/.local/share/nvim-lua`, `~/.local/state/nvim-lua`, `~/.local/cache/nvim-lua` (Neovim 0.9+
`NVIM_APPNAME` convention) — fully isolated from the primary build.

## Architecture

### Bootstrap order (init.lua)

```
config.options → config.keymaps → config.functions → config.macros → config.lazy
```

`config.lazy` bootstraps lazy.nvim and calls `require("lazy").setup("plugins")`, which
auto-loads every spec under `lua/plugins/*.lua`.

### Key directories

- `lua/config/` — core config, one concern per file (`options.lua`, `keymaps.lua`, `lazy.lua`, `macros.lua`).
- `lua/config/functions/` — custom line-manipulation functions (copy/move/delete/yank lines,
  duplicate-from-relative-line, visual-select-by-line-range), one file per function, ported
  from the vimscript build's `modules/functions/*.vim`. Aggregated via `functions/init.lua`.
- `lua/plugins/` — one file per plugin (lazy.nvim spec), same convention as the vimscript
  build's `modules/` directory.
- `macros/*.vim` — register-based macros (`let @x = '...'`) copied **byte-for-byte** (`cp`, not
  retyped) from the vimscript build, because they contain raw control characters that are easy
  to corrupt by hand-transcribing. `config/macros.lua` sources the always-on `macros.vim` plus
  exactly one language-specific set (currently `bash-macros.vim` — matches which one is
  uncommented in the vimscript build's `init.vim`). The language-specific sets reuse the same
  register letters (`m`, `g`, `b`, `y`), so only one can be active at a time; swap the active
  `source` line in `macros.lua` to switch (python/blade/css sets are already copied in, just
  not sourced).

### LSP & formatting

- **LSP**: `mason.nvim` + `mason-lspconfig.nvim` + `nvim-lspconfig`, configured for `ts_ls`
  (TypeScript/JavaScript) and `angularls` (Angular). `angularls` uses nvim-lspconfig's *default*
  `cmd` resolution (don't override it) — it walks the real `ngserver` binary path to find
  `@angular/language-service`, which under mason's npm install ends up nested at
  `node_modules/@angular/language-server/node_modules/@angular/language-service`, not the flat
  `node_modules/@angular/language-service`.
- Angular component templates (`*.component.html`) get filetype **`htmlangular`**, not `html` —
  both need entries anywhere a filetype-keyed table (formatters, etc.) is built.
- **Formatting**: `conform.nvim` + `prettier` (mason-installed fallback; prefers the project's
  own `node_modules/.bin/prettier` when present, so per-project `.prettierrc` overrides — e.g.
  `"parser": "angular"` for `*.html` — are honored). `format_on_save` is enabled, falling back
  to `vim.lsp.buf.format` for filetypes with no prettier entry. Manual format: `<M-l>`.
- **Snippets**: UltiSnips + vim-snippets (not LuaSnip — deliberately, to match the vimscript
  build's snippet engine). `UltiSnipsSnippetDirectories` includes the local `UltiSnips/` dir and,
  if present on the machine, the vimscript build's `UltiSnips/` directory too (existence-checked,
  so this build doesn't break on a machine that doesn't have the other repo cloned).
  `Tab`/`S-Tab` are driven through nvim-cmp, falling back to UltiSnips expand/jump.
- **No CoC.** `coc.nvim` and its extensions are intentionally not installed — running both a
  CoC client and native LSP on the same buffers would produce duplicate diagnostics/completion.
  If PHP or Python LSP support is needed here, add it as another native LSP server (mason +
  nvim-lspconfig), not CoC.

### Plugin manager

**lazy.nvim.** Commands: `:Lazy`, `:Lazy sync`, `:Lazy clean`. Lockfile: `lazy-lock.json`
(commit it — pins plugin versions).

Some plugins ship their own `lazy.lua` spec inside the plugin repo (a lazy.nvim convention) that
can silently override loading behavior — e.g. `yazi.nvim` ships one with `cmd`-only triggers,
which made its config (and our `<leader>e` keymap) never run until `lazy = false` was forced in
our own spec. If a plugin's keymaps mysteriously don't register, check
`require("lazy.core.config").plugins["<name>"].lazy` and `.cmd`/`.event`/`.keys`/`.ft` before
assuming the bug is in our config.

`jiangmiao/auto-pairs` is NOT used here — replaced with `windwp/nvim-autopairs`. The old
vimscript-era auto-pairs throws `E716: Key not present in Dictionary: "rhs"` /
`E121: Undefined variable: old_cr` on any buffer where other plugins register Lua-callback
keymaps (no string `rhs`) — which is most of this config.

### Conventions (carried over from the vimscript build for muscle memory)

- **Leader key**: `<Space>`. Indentation: 2 spaces. Relative numbers on in normal mode, off in
  insert. Clipboard: `unnamedplus`. Folding: indent-based, `foldlevelstart=99`.
- **Fuzzy finding is split across two tools, deliberately, to avoid a `<leader>f` timeout clash**:
  - `fzf.vim` owns `<leader>f*` — `ff` files, `fb` buffers, `fg`/`rg` grep, `fs` vsplit+files,
    `fw` files pre-filled with cword, `fr` GFiles?, `fc` commits, `fd` Gdiff, `fm` BCommits.
  - `telescope.nvim` owns `<leader>t*` — `tf` find_files, `tb` buffers, `tg` live_grep, `th` help_tags.
- **File explorer**: `yazi.nvim`, `<leader>e` (at current file), `<leader>cw` (at cwd) — not
  nvim-tree, to match the vimscript build.
- **Git**: `gitsigns.nvim` (`]c`/`[c` hunk nav, `<leader>hp/hd/hD`, `ih` hunk textobj),
  `lazygit.nvim` (`<leader>lz`), `vim-fugitive` (no custom binds beyond fzf.vim's `fr/fc/fd/fm`).
- **LSP keymaps**: `K` hover, `gd` definition, `gy` type definition, `gr` references,
  `gi` implementation, `<leader>rn` rename, `<leader>ca` code action, `<M-l>` format,
  `[g`/`]g` diagnostics.
- **Direct (no-leader) fenced-code-block mappings** (vim-surround based, count-prefixable):
  `ts`/`py`/`ph`/`mb`/`mj`/`my`/`ms`/`mg`/`mm`/`mv`/`mh`/`mc`/`mz`.
- **Custom line functions** (`lua/config/functions/`): `<leader>lc` copy lines,
  `<leader>ld` delete lines, `<leader>lm` move lines, `<leader>lv` visual-select lines,
  `<leader>ly` yank lines (all by absolute line number, prompted), `<leader>dl` delete empty
  lines relative to cursor, `<leader>lf`/`:CopyFrom N` duplicate lines from a relative offset,
  `<leader>vs` yank a `class="..."` attribute value at a line into register `i`.
- **File path copy**: `<leader>yr/ya/yn/yd` — same as the vimscript build.

## Working with this config

- Add a plugin: create `lua/plugins/<name>.lua` returning a lazy.nvim spec table; it's picked
  up automatically, no manual `require` needed.
- Add a keymap/option that isn't plugin-specific: `lua/config/keymaps.lua` / `options.lua`.
- Reload: restart Neovim (no `:source %`-style live reload convention here yet).
- When porting anything else from the vimscript build (`/home/serii/Documents/Apps/nvim`),
  check for CoC-specific bindings/settings first — those don't have a 1:1 equivalent here and
  need a native-LSP or conform.nvim replacement instead of a direct port.

## Known machine-specific bits

- `lua/plugins/ultisnips.lua` only adds the vimscript build's `UltiSnips/` directory if it
  exists on the current machine (`isdirectory` check) — on a machine without that other repo
  cloned, this build still works, just without those extra snippets.
- `lua/plugins/dadbod.lua` has a local Postgres connection string (`g:dbs`) pointing at
  `localhost` with a personal dev password — harmless on any machine (it's just a saved
  connection preset), but worth knowing it's sitting in this file if the repo is ever made public.
