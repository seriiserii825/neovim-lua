-- Yanks the value of a class="..." attribute at a given line into register i
local function yank_string_at_line(count)
  vim.opt.relativenumber = false
  vim.cmd("redraw")

  local target
  if count > 0 then
    target = count
  else
    local input = vim.fn.input("Line: ")
    if input == "" then
      vim.opt.relativenumber = true
      return
    end

    if input:match("^[+-]%d+$") then
      target = vim.fn.line(".") + tonumber(input)
    else
      target = tonumber(input) or 0
    end
  end

  local line = vim.fn.getline(target)
  local class = line:match('class="([^"]*)"')

  if class then
    vim.fn.setreg("i", class)
  else
    vim.api.nvim_echo({ { "No class attribute found", "ErrorMsg" } }, false, {})
  end

  vim.opt.relativenumber = true
end

vim.keymap.set("n", "<leader>vs", function()
  yank_string_at_line(vim.v.count)
end)
