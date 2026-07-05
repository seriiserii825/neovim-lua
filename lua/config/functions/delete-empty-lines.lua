-- Deletes EMPTY lines from the current line to current + {relative}
local function delete_empty_from_relative(relative)
  local cur = vim.fn.line(".")
  local rel = tonumber(relative) or 0

  local start = cur
  local finish = cur + rel

  if finish < start then
    start, finish = finish, start
  end

  start = math.max(1, start)
  finish = math.min(vim.fn.line("$"), finish)

  vim.cmd(start .. "," .. finish .. "g/^$/d")
end

vim.api.nvim_create_user_command("DelEmptyFromRelative", function(opts)
  delete_empty_from_relative(opts.args)
end, { nargs = 1 })

vim.keymap.set("n", "<leader>dl", function()
  delete_empty_from_relative(vim.fn.input("Delete empty from relative line: "))
end)
