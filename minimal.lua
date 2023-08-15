-- ignore default config and plugins
vim.opt.runtimepath:remove(vim.fn.expand('~/.config/nvim'))
vim.opt.packpath:remove(vim.fn.expand('~/.local/share/nvim/site'))

-- append test directory
local test_dir = '/tmp/nvim-config'
vim.opt.runtimepath:append(vim.fn.expand(test_dir))
vim.opt.packpath:append(vim.fn.expand(test_dir))

-- install packer
local install_path = test_dir .. '/pack/packer/start/packer.nvim'
local install_plugins = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.cmd('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd('packadd packer.nvim')
    install_plugins = true
end

local packer = require('packer') 

packer.init({
    package_root = test_dir .. '/pack',
    compile_path = test_dir .. '/plugin/packer_compiled.lua'
})

packer.startup(function(use)
    -- Packer can manage itself
    use('wbthomason/packer.nvim')

    -- lua functions for other plugins
    use("nvim-lua/plenary.nvim")

    -- treesitter
    use("nvim-treesitter/nvim-treesitter")

    -- nvim-dap (debugger adapter protocol)
    use("mfussenegger/nvim-dap")
    use("mfussenegger/nvim-dap-python")
    use{"rcarriga/nvim-dap-ui"}

    if install_plugins then
        packer.sync()
    end
end)

-- import nvim-treesitter plugin safely
local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
    return
end

treesitter.setup({
    -- enable syntax highlighting
    highlight = {
        enable = true,
    },
    -- enable indentation
    indent = { enable = true },
    -- enable autotagging (w/ nvim-ts-autotag plugin)
    autotag = { enable = true },
    -- ensure these language parsers are installed
    ensure_installed = {
      "python",
      "cpp",
      "cmake",
    },
    -- auto install above language parsers
    auto_install = true,
})

-- nvim-dap setup
local status, dap = pcall(require, "dap")
if not status then
    return
end

dap.adapters.lldb = {
    type = 'executable',
    command = 'lldb-vscode', -- adjust as needed, must be absolute path
    name = 'lldb'
}

-- nvim-dap C++ config
dap.configurations.cpp = {
    {
        name = 'Launch',
        type = 'lldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
    },
}

dap.configurations.c = dap.configurations.cpp

-- nvim-dap-python setup
local status, dap_python = pcall(require, "dap-python")
if not status then
    return
end

dap_python.setup("~/.config/debugpy/bin/python")

-- nvim-dap-ui setup
local status, dap_ui = pcall(require, "dapui")
if not status then
    return
end

dap_ui.setup()

-- key mappings
vim.g.mapleader = " "

-- nvim-dap debugging
vim.keymap.set("n", "<leader>d", ":lua require('dapui').toggle()<cr>")
vim.keymap.set("n", "db", ":lua require('dap').toggle_breakpoint()<cr>")
vim.keymap.set("n", "dc", ":lua require('dap').continue()<cr>")
vim.keymap.set("n", "dl", ":lua require('dap').run_last()<cr>")
vim.keymap.set("n", "ds", ":lua require('dap').step_over()<cr>")
vim.keymap.set("n", "di", ":lua require('dap').step_into()<cr>")
vim.keymap.set("n", "do", ":lua require('dap').step_out()<cr>")
vim.keymap.set("n", "dq", ":lua require('dap').disconnect({ terminateDebuggee = true })<cr>")

print("nvim ready!")

