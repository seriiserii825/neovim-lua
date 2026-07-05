local function yank_lines_absolute()
  vim.opt.relativenumber = false
  vim.cmd("redraw")

  local input = vim.fn.input("Lines (e.g. 4,8): ")
  if input == "" then
    vim.opt.relativenumber = true
    return
  end

  local parts = vim.split(input, ",")
  if #parts ~= 2 then
    vim.notify("Invalid format. Use: 4,8")
    vim.opt.relativenumber = true
    return
  end

  local start = math.max(1, tonumber(parts[1]) or 0)
  local finish = math.min(vim.fn.line("$"), tonumber(parts[2]) or 0)

  if start > finish then
    start, finish = finish, start
  end

  local lines = vim.fn.getline(start, finish)
  vim.fn.setreg("+", table.concat(lines, "\n"))
  vim.opt.relativenumber = true
end

vim.keymap.set("n", "<leader>ly", yank_lines_absolute)
