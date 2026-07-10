# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Lua-only Neovim configuration using **lazy.nvim** as the plugin manager and **native LSP**
(`nvim-lspconfig` + `mason.nvim`) instead of CoC. This is now the only Neovim config in use — the
old VimScript+CoC build (formerly at `/home/serii/Documents/Apps/nvim`, moved to `nvim-coc`) is
retired and no longer used. This build is self-contained: its own `UltiSnips/` and `macros/` are
committed here (copied byte-for-byte from that old build once), so cloning just this repo on a
new machine is enough.

It runs under the default Neovim profile — `~/.config/nvim` is a symlink to this repo, plain
`nvim` (and `$EDITOR`/`$VISUAL`) just works, no `NVIM_APPNAME` needed. Data/state/cache live under
the default `~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/nvim`.

On a new machine (e.g. work laptop): clone this repo to `~/.config/nvim` before the first `nvim`
invocation. First launch bootstraps lazy.nvim and mason installs ts_ls/angularls/
emmet_language_server/intelephense/prettier — needs internet, takes a couple minutes. Needed on
`$PATH`: `git`, `node`+`npm`, `rg` (ripgrep, fzf.vim's default source), `yazi`, `lazygit`.

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
- `UltiSnips/*.snippets` — same byte-for-byte-copy approach as `macros/`, copied from the
  vimscript build's `UltiSnips/` once. Not symlinked/synced automatically — if you add/edit a
  snippet in one build, copy it over manually to keep them in sync.

### LSP & formatting

- **LSP**: `mason.nvim` + `mason-lspconfig.nvim` + `nvim-lspconfig`, configured for:
  - `ts_ls` (TypeScript/JavaScript) — plain defaults.
  - `angularls` (Angular) — uses nvim-lspconfig's *default* `cmd` resolution (don't override
    it) — it walks the real `ngserver` binary path to find `@angular/language-service`, which
    under mason's npm install ends up nested at
    `node_modules/@angular/language-server/node_modules/@angular/language-service`, not the
    flat `node_modules/@angular/language-service`.
  - `intelephense` (PHP/WordPress) — settings ported from the old build's `coc-settings.json`
    (`environment.includePaths` for WP/WooCommerce/ACF core stubs, `format.enable`,
    `diagnostics.*`). `filetypes` extended with `php.blade` (see next bullet).
  - `emmet_language_server` (abbreviation completion) — `filetypes` extended beyond
    nvim-lspconfig's default list with `php`/`blade`/`php.blade`/`markdown`, matching the old
    build's `coc-emmet` + `emmet.includeLanguages` setting. `olrtg/nvim-emmet` (separate plugin,
    `<leader>xe`) is a thin extra for wrap-in-abbreviation; it does **not** run the LSP itself.
- Two filetype gotchas that anything filetype-keyed (LSP `filetypes`, conform formatters, etc.)
  needs to account for:
  - Angular component templates (`*.component.html`) get filetype **`htmlangular`**, not `html`.
  - `*.blade.php` is force-set to filetype **`php.blade`** (see `ultisnips.lua`'s autocmd), not
    plain `php`.
- **Formatting**: `conform.nvim` + `prettier` (mason-installed fallback; prefers the project's
  own `node_modules/.bin/prettier` when present, so per-project `.prettierrc` overrides — e.g.
  `"parser": "angular"` for `*.html` — are honored). `format_on_save` is enabled, falling back
  to `vim.lsp.buf.format` for filetypes with no prettier entry (e.g. `php` → intelephense's own
  formatter). Manual format: `<M-l>`.
- **Snippets**: UltiSnips + vim-snippets (not LuaSnip — LuaSnip has no built-in loader for the
  UltiSnips `.snippets` file format, so switching engines would mean hand-rewriting every
  snippet; not worth it just to fix the bug described below). Snippet files live in this repo's
  own `UltiSnips/` (see above). Initial expansion goes through nvim-cmp's popup (`Tab` confirms
  the selected candidate), not a raw `UltiSnips#ExpandSnippet()` call — see the cmp.lua note
  below for why, including a bug in `cmp-nvim-ultisnips` itself that undermined this.
- **No CoC.** `coc.nvim` and its extensions are intentionally not installed — running both a
  CoC client and native LSP on the same buffers would produce duplicate diagnostics/completion.
  If more language support is needed here, add it as another native LSP server (mason +
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

**cmp.lua's `<Tab>` never calls `UltiSnips#ExpandSnippet()`/`CanExpandSnippet()` directly.**
When two snippet triggers overlap by suffix (e.g. `php.snippets` has both `v` and `dv`),
UltiSnips can't tell which one you mean from raw text-before-cursor matching and throws up a
blocking `Confirm` chooser popup. Going through nvim-cmp's own (prefix-filtered) candidate list
via `cmp-nvim-ultisnips` and confirming *that* is meant to sidestep the ambiguity entirely — set
`cmp_nvim_ultisnips`'s `show_snippets = "all"` too (not the default `"expandable"`, which asks
UltiSnips the same ambiguous "what can expand here" question under the hood).

That alone isn't enough, though: `cmp-nvim-ultisnips`'s own `source:execute()`
(`lua/cmp_nvim_ultisnips/source.lua`) ignores which candidate cmp actually resolved and just
calls the raw `UltiSnips#ExpandSnippet()` on confirm anyway — silently reintroducing the exact
same ambiguous chooser at confirm time, which can wedge the buffer/statusline (bufferline
included) if you answer it mid-insert. `cmp.lua` patches `cmpu_source.execute` after requiring
`cmp_nvim_ultisnips.source` to instead delete the just-inserted trigger text and expand the
already-resolved `completion_item.snippet.value` directly via `UltiSnips#Anon` — no re-matching,
no ambiguity, no popup. Popup navigation is on `<C-j>`/`<C-k>` (matching the CoC build's
`coc#pum#next/prev`), not `<Tab>` — `<Tab>` checks `UltiSnips#CanJumpForwards` *before*
`cmp.visible()`, so it jumps to the next tabstop of an already-active snippet first, only
falling back to confirming the selected completion candidate (or a literal tab) when no snippet
is active. This order matters: checking `cmp.visible()` first used to let stray completions
(e.g. emmet_language_server suggesting a full `<h2></h2>` while you're mid-edit on a tabstop
like `dv`'s tag-name `$1`) hijack `<Tab>` and splice themselves into the snippet instead of
jumping to `$2`.

**`copilot#Accept()` (bound to `<C-l>`, insert mode) must stay a real vimscript `:imap`,
not a `vim.keymap.set` Lua string.** Its return value is a raw keystroke sequence
(`<C-R><C-R>=...<CR>`, similar in spirit to the register macros) that Neovim's `<expr>`-mapping
machinery re-feeds and expands; porting it through Lua string escaping mangled it into literal
garbage bytes in the buffer. See `lua/plugins/copilot.lua` — it uses `vim.cmd([[imap ...]])`
with the exact text from copilot.vim's own docs instead.

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
  `[g`/`]g` diagnostics, `<leader>cp` view diagnostic float under cursor, `<leader>ia`
  fix all imports (addMissingImports → removeUnused → organizeImports, ts_ls-specific
  code action kinds, ported from the old coc.vim build's `fix_all_imports()`). Emmet
  wrap: `<leader>xe`.
- **Buffers/windows** (`lua/plugins/bufferline.lua` — these live there, not `keymaps.lua`,
  because in the vimscript build they're all defined in `modules/bufferline.vim`, sourced
  *after* `keys/map-nvim.vim`, so they win over that file's own `<leader>w`/`<leader>z`):
  `<S-h>/<S-l>` cycle buffers, `<M-S-h>/<M-S-l>` move buffer, `<leader>1..0` go to buffer N,
  `<leader>qr/qa/qo` close right/others/all-but-current, `<leader>w` save **all** buffers
  (`:wa`), `<leader>z` quit-all (`:qa`, refuses if any buffer has unsaved changes), `<leader>bo`
  `:only`, `<leader>br` reload current
  buffer from disk keeping cursor position. The trailing-double-space cleanup that used to be
  `<leader>z` in `map-nvim.vim` (shadowed there too) lives at `<leader>zs` here.
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

## Known machine-specific bits

- `lua/plugins/lsp.lua`'s `intelephense` config has a hardcoded list of WordPress/WooCommerce/
  ACF core paths under `/home/serii/Documents/...` (`environment.includePaths`) for better
  completion/diagnostics in WP theme/plugin work. Harmless if missing on another machine
  (intelephense just won't find them, no error) — update the paths if those projects live
  somewhere else there.
- `lua/plugins/dadbod.lua` has a local Postgres connection string (`g:dbs`) pointing at
  `localhost` with a personal dev password — harmless on any machine (it's just a saved
  connection preset), but worth knowing it's sitting in this file if the repo is ever made public.
