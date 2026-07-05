return {
  {
    "tpope/vim-surround",
    init = function()
      vim.g["surround_" .. string.byte("t")] = "```ts\n\r\n```"
      vim.g["surround_" .. string.byte("p")] = "```python\n\r\n```"
      vim.g["surround_" .. string.byte("z")] = "```prisma\n\r\n```"
      vim.g["surround_" .. string.byte("b")] = "```bash\n\r\n```"
      vim.g["surround_" .. string.byte("y")] = "```yaml\n\r\n```"
      vim.g["surround_" .. string.byte("j")] = "```json\n\r\n```"
      vim.g["surround_" .. string.byte("g")] = "```graphql\n\r\n```"
      vim.g["surround_" .. string.byte("m")] = "```vim\n\r\n```"
      vim.g["surround_" .. string.byte("v")] = "```vue\n\r\n```"
      vim.g["surround_" .. string.byte("s")] = "```sql\n\r\n```"
      -- 'h' is used twice upstream (php then html); html wins, matching the vimscript build
      vim.g["surround_" .. string.byte("h")] = "```html\n\r\n```"
      vim.g["surround_" .. string.byte("c")] = "```scss\n\r\n```"
    end,
    config = function()
      -- wrap N lines (v:count1) in a ```lang fenced code block
      local function surround_with(lang, count)
        local c = math.max(1, count)
        local steps = math.min(c - 1, vim.fn.line("$") - vim.fn.line("."))

        vim.cmd("normal! V")
        if steps > 0 then
          vim.cmd("normal! " .. steps .. "j")
        end

        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>VSurround" .. lang, true, true, true), "m")
      end

      local function map_surround(lhs, lang)
        vim.keymap.set("n", lhs, function()
          surround_with(lang, vim.v.count1)
        end, { silent = true })
      end

      map_surround("ts", "t")
      map_surround("py", "p")
      map_surround("ph", "h")
      map_surround("mz", "z")
      map_surround("mb", "b")
      map_surround("my", "y")
      map_surround("mj", "j")
      map_surround("mg", "g")
      map_surround("ms", "s")
      map_surround("mm", "m")
      map_surround("mv", "v")
      map_surround("mh", "h")
      map_surround("mc", "c")

      vim.api.nvim_create_user_command("Dash", function(opts)
        local n = tonumber(opts.args)
        vim.cmd(string.format("%d,%d normal! I- ", vim.fn.line("."), vim.fn.line(".") + n))
      end, { nargs = 1 })
      vim.keymap.set("n", "dh", function()
        vim.cmd("Dash " .. vim.v.count1)
      end, { silent = true })

      vim.keymap.set("n", "<leader>rt", function()
        local new_tag = vim.fn.input("New tag name: ")
        if new_tag == "" then
          return
        end

        vim.cmd("normal! vato")
        local old_tag = vim.fn.expand("<cword>")
        vim.cmd(([[%%s/<%s\(\s\|>\)/<%s\1/ge]]):format(old_tag, new_tag))
        vim.cmd(([[%%s/<\/%s>/<\/%s>/ge]]):format(old_tag, new_tag))
      end)
    end,
  },
}
