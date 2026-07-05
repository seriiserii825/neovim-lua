return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npx --yes yarn install",
    init = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_path_to_chrome = "/usr/bin/google-chrome-stable"
      vim.g.mkdp_theme = "dark"
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 1
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ""
      vim.g.mkdp_browser = "google-chrome-stable"
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_browserfunc = ""
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
      }
      vim.g.mkdp_port = ""
      vim.g.mkdp_page_title = "「${name}」"
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    config = function()
      vim.keymap.set("n", "<leader>mp", "<Plug>MarkdownPreviewToggle")
    end,
  },
}
