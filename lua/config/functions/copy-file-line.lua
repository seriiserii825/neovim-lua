-- Copies "path: ...\nLine: N" (plus any diagnostics on the current line) to the clipboard
local function copy_file_line_with_diagnostics()
  local path = vim.fn.expand("%:p")
  local lnum = vim.fn.line(".")
  local result = string.format("path: %s\nLine: %d", path, lnum)

  local diagnostics = vim.diagnostic.get(0, { lnum = lnum - 1 })
  if #diagnostics > 0 then
    result = result .. "\nDiagnostics:"
    for _, d in ipairs(diagnostics) do
      local severity = vim.diagnostic.severity[d.severity] or "ERROR"
      result = result .. string.format("\n[%s] %s", severity, d.message)
    end
  end

  vim.fn.setreg("+", result)
end

vim.keymap.set("n", "<leader>cfl", copy_file_line_with_diagnostics, { silent = true })
