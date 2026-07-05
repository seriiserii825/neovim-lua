local function delete_lines_absolute()
  vim.opt.relativenumber = false
  vim.cmd("redraw")

  local input = vim.fn.input("Lines (e.g. 23,88): ")
  if input == "" then
    vim.opt.relativenumber = true
    return
  end

  local parts = vim.split(input, ",")
  local start, finish

  if #parts == 1 then
    start = math.max(1, tonumber(parts[1]) or 0)
    finish = start
  elseif #parts == 2 then
    start = math.max(1, tonumber(parts[1]) or 0)
    finish = math.min(vim.fn.line("$"), tonumber(parts[2]) or 0)
  else
    vim.notify("Invalid format. Use: 23 (one line) or 23,88 (range)")
    vim.opt.relativenumber = true
    return
  end

  if start > finish then
    start, finish = finish, start
  end

  vim.cmd(start .. "," .. finish .. "delete _")
  vim.notify("Deleted lines " .. start .. " to " .. finish)
  vim.opt.relativenumber = true
end

vim.keymap.set("n", "<leader>ld", delete_lines_absolute)
