return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
            sync_install = false,
            auto_install = true,
            indent = {
                enable = true,
                disable = { 'ruby' }
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = { 'ruby' },
            },
        })
    end
}
