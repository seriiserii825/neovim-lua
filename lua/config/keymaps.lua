local map = vim.keymap.set

-- <leader>w and <leader>z are set in bufferline.lua (:wa and :wq) -- that's
-- what's actually active in the vimscript build, since bufferline.vim is
-- sourced after this file's vimscript equivalent (keys/map-nvim.vim) and wins.
map("n", "<leader>q", ":q<CR>")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- ported from the vimscript build's keys/map-nvim.vim (CoC-specific mappings excluded)

vim.api.nvim_create_user_command("RemToPx", function()
  vim.cmd([[%s/\(\d\+\.\?\d*\)rem/\=string(str2float(submatch(1)) * 10) . 'px'/g]])
end, {})
map("n", "<leader>px", ":RemToPx<CR>")

map("n", "<leader>ri", [[:%s/export interface \(\w\+\)/export interface I\1/g | nohlsearch<CR>]])

map("v", "<leader>t", [[:'<,'>!trans -b :en<CR>]])

-- visual inside quotes
map("n", [[<leader>v"]], [[vi"]])
map("n", [[<leader>v']], [[vi']])

-- copy inside quotes
map("n", [[<leader>y"]], [[vi"y]])
map("n", [[<leader>y']], [[vi'y]])
map("n", [[<leader>y`]], [[vi`y]])

-- paste inside quotes
map("n", [[<leader>p"]], [[:normal! f"pf"<CR>]])
map("n", [[<leader>p']], [[:normal! f'pf'<CR>]])
map("n", [[<leader>p`]], [[:normal! f`pf`<CR>]])

map("n", "<leader>a", ":bufdo w<CR>")
map("n", "_", "i <Esc>")

map("n", "<leader>ns", ":set spell!<CR>", { silent = true })

map("i", "<C-i>", "<C-r>=@i<CR>")

-- remove trailing spaces (was <leader>z in map-nvim.vim, but that's shadowed
-- by bufferline.vim's <leader>z = :wq in the vimscript build; moved here to
-- keep the feature reachable)
map("n", "<leader>zs", [[:%s/\s\{2,}/ /g<CR>]], { silent = true })

-- open current file in browser
map("n", "<leader>ob", [[:w | !google-chrome-stable "%"<CR>]], { silent = true })

map("n", "<leader>sn", ":source $MYVIMRC<CR>", { silent = true })
map("n", "<leader>sf", ":source %<CR>", { silent = true })

-- count symbols in the clipboard register
map("n", "<C-t>", ":let @+ = len(@+)<CR>", { silent = true })

-- wrap `inline code` into a fenced code block
map("n", "<leader>ms", [[:%s/`\(.*\)`/```\r\1\r```/g<CR>]])

map("n", "<leader>xr", [[:g/^\s*$/d<CR>]], { silent = true })
map("n", "<leader>xl", [[:%s/^[ \t]*//<CR>]], { silent = true })

-- rename word under cursor (yank then prefill a substitute command)
map("v", "<leader>rn", [["zy:s/<C-r>z/]])
map("v", "<leader>rna", [["zy:%s/<C-r>z/]])

-- file path yanks
map("n", "<leader>yr", ':let @+=expand("%")<CR>', { silent = true })
map("n", "<leader>ya", ':let @+=expand("%:p")<CR>', { silent = true })
map("n", "<leader>yn", ':let @+=expand("%:t")<CR>', { silent = true })
map("n", "<leader>yd", ':let @+=expand("%:p:h")<CR>', { silent = true })

map("n", "[n", ":set relativenumber!<CR>")

-- reselect pasted text
map("n", "gp", "`[v`]")

map("n", "<leader>nh", ":nohl<CR>")

-- resize windows
map("n", "<C-Down>", ":resize -2<CR>")
map("n", "<C-Up>", ":resize +2<CR>")
map("n", "<C-Left>", ":vertical resize -2<CR>")
map("n", "<C-Right>", ":vertical resize +2<CR>")

map("i", "jj", "<Esc>")

-- ported from settings.vim: select N lines up/down from the cursor, relative to it
vim.api.nvim_create_user_command("VRel", function(opts)
  local a1 = tonumber(opts.fargs[1])
  local a2 = tonumber(opts.fargs[2])
  local l1 = vim.fn.line(".") + a1
  local l2 = vim.fn.line(".") + a2

  if l1 > l2 then
    vim.cmd(l1 .. "normal! V" .. l2 .. "G")
  else
    vim.cmd(l2 .. "normal! V" .. l1 .. "G")
  end
end, { nargs = "+" })
