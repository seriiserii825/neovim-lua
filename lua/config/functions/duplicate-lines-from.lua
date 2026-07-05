local function duplicate_lines_from(from)
  local cur = vim.fn.line(".")
  local start = cur + (tonumber(from) or 0)
  local finish = cur

  if start > finish then
    start, finish = finish, start
  end

  start = math.max(1, start)
  finish = math.min(vim.fn.line("$"), finish)

  vim.cmd(start .. "," .. finish .. "t" .. cur)
end

vim.api.nvim_create_user_command("CopyFrom", function(opts)
  duplicate_lines_from(opts.args)
end, { nargs = 1 })

vim.keymap.set("n", "<leader>lf", function()
  duplicate_lines_from(vim.fn.input("Copy from relative line: "))
end)
