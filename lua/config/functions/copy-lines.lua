local function copy_lines_absolute()
  vim.opt.relativenumber = false
  vim.cmd("redraw")

  local input = vim.fn.input("Lines (e.g. 4,8,44): ")
  if input == "" then
    vim.opt.relativenumber = true
    return
  end

  local parts = vim.split(input, ",")
  local start, finish, dest

  if #parts == 2 then
    start = math.max(1, tonumber(parts[1]) or 0)
    finish = start
    dest = math.max(0, math.min(vim.fn.line("$"), tonumber(parts[2]) or 0))
  elseif #parts == 3 then
    start = math.max(1, tonumber(parts[1]) or 0)
    finish = math.min(vim.fn.line("$"), tonumber(parts[2]) or 0)
    dest = math.max(0, math.min(vim.fn.line("$"), tonumber(parts[3]) or 0))
  else
    vim.notify("Invalid format. Use: 4,44 (one line) or 4,8,44 (range)")
    vim.opt.relativenumber = true
    return
  end

  if start > finish then
    start, finish = finish, start
  end

  vim.cmd(start .. "," .. finish .. "t" .. dest)
  vim.opt.relativenumber = true
end

vim.keymap.set("n", "<leader>lc", copy_lines_absolute)
