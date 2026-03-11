-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                                                                        ║
-- ║   ███████╗██████╗ ██╗██████╗ ███████╗██████╗ ██╗███████╗               ║
-- ║   ██╔════╝██╔══██╗██║██╔══██╗██╔════╝██╔══██╗╚═╝██╔════╝               ║
-- ║   ███████╗██████╔╝██║██║  ██║█████╗  ██████╔╝   ███████╗               ║
-- ║   ╚════██║██╔═══╝ ██║██║  ██║██╔══╝  ██╔══██╗   ╚════██║               ║
-- ║   ███████║██║     ██║██████╔╝███████╗██║  ██║   ███████║               ║
-- ║   ╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚══════╝               ║
-- ║                       L    A    B                                      ║
-- ║                                                                        ║
-- ║   "Listen, you guys. There is NO right and wrong.                      ║
-- ║    There's only fun and boring." — The Plague                          ║
-- ║   (He was wrong about everything. Except this config.)                 ║
-- ║                                                                        ║
-- ║   Neovim init.lua — lazy.nvim modular configuration.                   ║
-- ║   Tuned for RTX 3060 terminal rendering. Zero compromise.              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 0: CORE OPTIONS                                                 ║
-- ║  // Zero Cool here. First thing — set up the terminal right.           ║
-- ║  // No line numbers cluttering the view. Relative if you need 'em.     ║
-- ║  // We're not writing essays. We're writing exploits.                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local opt = vim.opt

-- // Display — keep it clean. Relative numbers for surgical jumps.
opt.number = false
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false
opt.cmdheight = 1
opt.laststatus = 3

-- // Indentation — 4 spaces. Tabs are for amateurs.
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

-- // Search — case-insensitive until you mean it.
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- // Splits — open right and below. Natural reading order.
opt.splitright = true
opt.splitbelow = true

-- // Performance — the RTX 3060 can handle anything we throw at it.
-- // But we're still surgical. Low updatetime. No swap lag.
opt.updatetime = 100
opt.timeoutlen = 300
opt.swapfile = false
opt.undofile = true

-- // Scrolling — keep 8 lines of context. Never code blind.
opt.scrolloff = 8
opt.sidescrolloff = 8

-- // Clipboard — system clipboard. What you yank here, you paste everywhere.
opt.clipboard = "unnamedplus"

-- // Mouse — yes, even hackers use mice sometimes. Don't judge.
opt.mouse = "a"

-- // Completion — sensible popup behavior.
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 12

-- // Wrapping — off. Lines go as far as they need to.
opt.wrap = false

-- // Fill chars — clean vertical splits.
opt.fillchars = { eob = " ", vert = "│" }

-- // Compat shims — nvim-treesitter v1.0 removed parsers/configs modules
-- // but Telescope still requires them. Preload shims into package.loaded
-- // so Telescope's pcall(require, ...) finds them before it falls over.
if not pcall(require, "nvim-treesitter.parsers") then
    package.loaded["nvim-treesitter.parsers"] = {
        ft_to_lang = function(ft)
            return vim.treesitter.language.get_lang(ft) or ft
        end,
        get_parser = function(bufnr, lang)
            local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
            if ok and parser then return parser end
            return nil
        end,
    }
end
if not pcall(require, "nvim-treesitter.configs") then
    package.loaded["nvim-treesitter.configs"] = {
        is_enabled = function(_, lang, bufnr)
            -- // Guard: check both that the language parser exists AND that it
            -- // can attach to this specific buffer. Telescope preview buffers
            -- // can be empty/scratch — get_parser throws on those.
            local lang_ok = pcall(vim.treesitter.language.add, lang)
            if not lang_ok then return false end
            local ok, parser = pcall(vim.treesitter.get_parser, bufnr or 0, lang)
            return ok and parser ~= nil
        end,
        get_module = function()
            return { additional_vim_regex_highlighting = false }
        end,
    }
end


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 1: LEADER KEY                                                   ║
-- ║  // Space. The final frontier. Also our leader key.                    ║
-- ║  // Every command starts with a thought. Every thought starts here.    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 2: BOOTSTRAP LAZY.NVIM                                         ║
-- ║  // The package manager. It's lazy, but it's fast.                     ║
-- ║  // First boot? It'll clone itself. Sit tight.                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 3: SPIDER-NEON COLORSCHEME                                     ║
-- ║  // This is our signature. Our fingerprint on every buffer.            ║
-- ║  // Transparent background — see through to the matrix.                ║
-- ║  // Electric Cyan foreground. Spider-Red keywords.                     ║
-- ║  // Neon Magenta strings. Everything else? Calibrated.                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local function apply_spider_neon()
    vim.cmd("highlight clear")
    vim.g.colors_name = "spider-neon"

    -- // Color palette — Fluoromachine. Deep purple void. Neon edges.
    local c = {
        none       = "NONE",
        bg         = "NONE",           -- Transparent. See through the glass.
        fg         = "#E8E3E3",        -- Warm white — clean, readable text.
        red        = "#FC199A",        -- Hot Pink — keywords, danger, power.
        magenta    = "#AF6DF9",        -- Neon Purple — strings, accents.
        green      = "#72F1B8",        -- Fluoromachine Mint — success signals.
        yellow     = "#FFCC00",        -- Neon Yellow — warnings, constants.
        blue       = "#5C73E6",        -- Soft Blue — functions, depth.
        cyan       = "#61E2FF",        -- Electric Cyan — primary data color.
        white      = "#E8E3E3",        -- Warm White — secondary text.
        dim        = "#6B5F7B",        -- Muted Purple — comments, noise.
        dark       = "#191724",        -- Deep Purple void — subtle backgrounds.
        bright_red = "#FE5EB5",        -- Bright Pink — errors screaming.
        bright_cyan = "#8EEBFF",       -- Bright Cyan — highlights.
    }

    local hl = function(group, opts)
        vim.api.nvim_set_hl(0, group, opts)
    end

    -- ── Editor chrome ────────────────────────────────────────────
    hl("Normal",       { fg = c.fg, bg = c.bg })
    hl("NormalFloat",  { fg = c.fg, bg = c.dark })
    hl("FloatBorder",  { fg = c.red, bg = c.dark })
    hl("CursorLine",   { bg = "#241B30" })   -- Subtle purple glow. Deep in the void.
    hl("CursorLineNr", { fg = c.red, bold = true })
    hl("LineNr",       { fg = c.dim })
    hl("SignColumn",   { bg = c.bg })
    hl("VertSplit",    { fg = c.red, bg = c.bg })
    hl("WinSeparator", { fg = c.red, bg = c.bg })
    hl("StatusLine",   { fg = c.cyan, bg = c.dark })
    hl("StatusLineNC", { fg = c.dim, bg = c.dark })
    hl("Pmenu",        { fg = c.fg, bg = c.dark })
    hl("PmenuSel",     { fg = "#000000", bg = c.cyan })
    hl("PmenuSbar",    { bg = c.dark })
    hl("PmenuThumb",   { bg = c.red })
    hl("Visual",       { bg = "#2D2250" })
    hl("VisualNOS",    { bg = "#2D2250" })
    hl("Search",       { fg = "#000000", bg = c.yellow })
    hl("IncSearch",    { fg = "#000000", bg = c.magenta })
    hl("MatchParen",   { fg = c.magenta, bold = true, underline = true })
    hl("NonText",      { fg = "#222222" })
    hl("EndOfBuffer",  { fg = c.bg })
    hl("Folded",       { fg = c.dim, bg = c.dark })
    hl("FoldColumn",   { fg = c.dim, bg = c.bg })
    hl("ColorColumn",  { bg = "#1E1432" })
    hl("WildMenu",     { fg = "#000000", bg = c.cyan })
    hl("TabLine",      { fg = c.dim, bg = c.dark })
    hl("TabLineFill",  { bg = c.dark })
    hl("TabLineSel",   { fg = "#000000", bg = c.red, bold = true })
    hl("Title",        { fg = c.red, bold = true })
    hl("Directory",    { fg = c.cyan })
    hl("Question",     { fg = c.green })
    hl("MoreMsg",      { fg = c.green })
    hl("WarningMsg",   { fg = c.yellow })
    hl("ErrorMsg",     { fg = c.bright_red, bold = true })
    hl("ModeMsg",      { fg = c.cyan, bold = true })
    hl("SpecialKey",   { fg = c.dim })
    hl("Conceal",      { fg = c.dim })

    -- ── Syntax — the language of the machine ─────────────────────
    hl("Comment",      { fg = c.dim, italic = true })
    hl("Constant",     { fg = c.yellow })
    hl("String",       { fg = c.magenta })       -- Neon Magenta strings. Stand out.
    hl("Character",    { fg = c.magenta })
    hl("Number",       { fg = c.yellow })
    hl("Boolean",      { fg = c.yellow, bold = true })
    hl("Float",        { fg = c.yellow })
    hl("Identifier",   { fg = c.fg })
    hl("Function",     { fg = c.blue, bold = true })
    hl("Statement",    { fg = c.red })           -- Spider-Red keywords. Power.
    hl("Conditional",  { fg = c.red })
    hl("Repeat",       { fg = c.red })
    hl("Label",        { fg = c.red })
    hl("Operator",     { fg = c.white })
    hl("Keyword",      { fg = c.red, bold = true }) -- Spider-Red. No mercy.
    hl("Exception",    { fg = c.bright_red })
    hl("PreProc",      { fg = c.magenta })
    hl("Include",      { fg = c.magenta })
    hl("Define",       { fg = c.magenta })
    hl("Macro",        { fg = c.magenta })
    hl("PreCondit",    { fg = c.magenta })
    hl("Type",         { fg = c.cyan })
    hl("StorageClass", { fg = c.red })
    hl("Structure",    { fg = c.cyan })
    hl("Typedef",      { fg = c.cyan })
    hl("Special",      { fg = c.magenta })
    hl("SpecialChar",  { fg = c.magenta })
    hl("Tag",          { fg = c.red })
    hl("Delimiter",    { fg = c.white })
    hl("Debug",        { fg = c.bright_red })
    hl("Underlined",   { fg = c.cyan, underline = true })
    hl("Error",        { fg = c.bright_red, bold = true })
    hl("Todo",         { fg = "#000000", bg = c.red, bold = true })

    -- ── Treesitter overrides — surgical precision ────────────────
    hl("@variable",           { fg = c.fg })
    hl("@variable.builtin",   { fg = c.cyan, italic = true })
    hl("@variable.parameter", { fg = c.bright_cyan })
    hl("@constant",           { fg = c.yellow })
    hl("@constant.builtin",   { fg = c.yellow, bold = true })
    hl("@function",           { fg = c.blue, bold = true })
    hl("@function.builtin",   { fg = c.blue })
    hl("@function.call",      { fg = c.blue })
    hl("@method",             { fg = c.blue })
    hl("@method.call",        { fg = c.blue })
    hl("@keyword",            { fg = c.red, bold = true })
    hl("@keyword.function",   { fg = c.red })
    hl("@keyword.return",     { fg = c.red, italic = true })
    hl("@keyword.operator",   { fg = c.red })
    hl("@conditional",        { fg = c.red })
    hl("@repeat",             { fg = c.red })
    hl("@exception",          { fg = c.bright_red })
    hl("@include",            { fg = c.magenta })
    hl("@string",             { fg = c.magenta })
    hl("@string.escape",      { fg = c.bright_red })
    hl("@string.special",     { fg = c.magenta, bold = true })
    hl("@character",          { fg = c.magenta })
    hl("@number",             { fg = c.yellow })
    hl("@boolean",            { fg = c.yellow, bold = true })
    hl("@float",              { fg = c.yellow })
    hl("@type",               { fg = c.cyan })
    hl("@type.builtin",       { fg = c.cyan, italic = true })
    hl("@type.definition",    { fg = c.cyan, bold = true })
    hl("@attribute",          { fg = c.magenta })
    hl("@property",           { fg = c.fg })
    hl("@field",              { fg = c.fg })
    hl("@parameter",          { fg = c.bright_cyan })
    hl("@constructor",        { fg = c.cyan })
    hl("@operator",           { fg = c.white })
    hl("@punctuation",        { fg = c.white })
    hl("@punctuation.bracket", { fg = c.white })
    hl("@punctuation.delimiter", { fg = c.dim })
    hl("@punctuation.special", { fg = c.magenta })
    hl("@comment",            { fg = c.dim, italic = true })
    hl("@tag",                { fg = c.red })
    hl("@tag.attribute",      { fg = c.cyan })
    hl("@tag.delimiter",      { fg = c.dim })
    hl("@text.uri",           { fg = c.cyan, underline = true })
    hl("@text.emphasis",      { italic = true })
    hl("@text.strong",        { bold = true })
    hl("@text.title",         { fg = c.red, bold = true })
    hl("@namespace",          { fg = c.cyan, italic = true })

    -- ── Diagnostics — the system's immune response ──────────────
    hl("DiagnosticError",          { fg = c.bright_red })
    hl("DiagnosticWarn",           { fg = c.yellow })
    hl("DiagnosticInfo",           { fg = c.cyan })
    hl("DiagnosticHint",           { fg = c.green })
    hl("DiagnosticUnderlineError", { undercurl = true, sp = c.bright_red })
    hl("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
    hl("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.cyan })
    hl("DiagnosticUnderlineHint",  { undercurl = true, sp = c.green })
    hl("DiagnosticVirtualTextError", { fg = c.bright_red, italic = true })
    hl("DiagnosticVirtualTextWarn",  { fg = c.yellow, italic = true })
    hl("DiagnosticVirtualTextInfo",  { fg = c.cyan, italic = true })
    hl("DiagnosticVirtualTextHint",  { fg = c.green, italic = true })

    -- ── Git signs ────────────────────────────────────────────────
    hl("GitSignsAdd",    { fg = c.green })
    hl("GitSignsChange", { fg = c.yellow })
    hl("GitSignsDelete", { fg = c.red })

    -- ── Telescope — searching through the web ────────────────────
    hl("TelescopeNormal",       { fg = c.fg, bg = c.bg })
    hl("TelescopeBorder",       { fg = c.red, bg = c.bg })
    hl("TelescopeTitle",        { fg = c.red, bold = true })
    hl("TelescopePromptNormal", { fg = c.fg, bg = c.dark })
    hl("TelescopePromptBorder", { fg = c.red, bg = c.dark })
    hl("TelescopePromptTitle",  { fg = "#000000", bg = c.red, bold = true })
    hl("TelescopePromptPrefix", { fg = c.red })
    hl("TelescopeResultsNormal", { fg = c.fg, bg = c.bg })
    hl("TelescopeResultsBorder", { fg = c.red, bg = c.bg })
    hl("TelescopePreviewNormal", { fg = c.fg, bg = c.bg })
    hl("TelescopePreviewBorder", { fg = c.red, bg = c.bg })
    hl("TelescopePreviewTitle",  { fg = "#000000", bg = c.cyan, bold = true })
    hl("TelescopeSelection",     { fg = c.cyan, bg = "#241B30", bold = true })
    hl("TelescopeSelectionCaret", { fg = c.red })
    hl("TelescopeMatching",      { fg = c.magenta, bold = true })

    -- ── Dashboard — the splash ───────────────────────────────────
    hl("DashboardHeader",  { fg = c.red })
    hl("DashboardCenter",  { fg = c.cyan })
    hl("DashboardFooter",  { fg = c.dim, italic = true })
    hl("AlphaHeader",      { fg = c.red })
    hl("AlphaButtons",     { fg = c.cyan })
    hl("AlphaShortcut",    { fg = c.magenta })
    hl("AlphaFooter",      { fg = c.dim, italic = true })
end


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 4: PLUGIN SPECS                                                 ║
-- ║  // Alright, this is where we load our arsenal.                        ║
-- ║  // Every plugin is a tool. Every tool is a weapon.                    ║
-- ║  // Keep it lean. No bloat. Speed is survival.                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

require("lazy").setup({

    -- ══════════════════════════════════════════════════════════════
    --  TREESITTER — parsing the source code of reality
    --  // This is how we SEE code. Not as text. As structure.
    --  // AST-level highlighting. The machine reads with us.
    -- ══════════════════════════════════════════════════════════════
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            -- // nvim-treesitter v1.0 API — highlighting is built into Neovim 0.11+.
            -- // We just need to install parsers. The machine already knows how to see.
            require("nvim-treesitter").setup({})

            -- // Auto-install parsers on first encounter with a filetype.
            -- // Like the spider's web expanding to catch new prey.
            local parsers = {
                "lua", "python", "bash", "c", "cpp", "rust",
                "javascript", "typescript", "html", "css", "json",
                "yaml", "toml", "markdown", "markdown_inline",
                "vim", "vimdoc", "query", "regex", "go",
            }

            -- // Install missing parsers asynchronously.
            -- // Requires tree-sitter CLI. Skip if not available.
            vim.api.nvim_create_autocmd("VimEnter", {
                once = true,
                callback = function()
                    if vim.fn.executable("tree-sitter") ~= 1 then
                        return
                    end
                    local installed = require("nvim-treesitter.config").get_installed()
                    local installed_set = {}
                    for _, p in ipairs(installed) do
                        installed_set[p] = true
                    end
                    -- // Also check if parser is loadable via system packages.
                    local missing = {}
                    for _, p in ipairs(parsers) do
                        if not installed_set[p] then
                            local ok = pcall(vim.treesitter.language.add, p)
                            if not ok then
                                table.insert(missing, p)
                            end
                        end
                    end
                    if #missing > 0 then
                        require("nvim-treesitter.install").install(missing)
                    end
                end,
            })
        end,
    },

    -- ══════════════════════════════════════════════════════════════
    --  TELESCOPE — scanning the filesystem. Finding the target.
    --  // grep is for mortals. We use fuzzy finding.
    --  // Leader+ff = find files. Leader+fg = live grep.
    --  // The spider's web catches everything.
    -- ══════════════════════════════════════════════════════════════
    {
        "nvim-telescope/telescope.nvim",
        branch = "master",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function()
                    return vim.fn.executable("make") == 1
                end,
            },
        },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Spider's LAB — Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Spider's LAB — Live Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Spider's LAB — Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Spider's LAB — Help Tags" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Spider's LAB — Diagnostics" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>",   desc = "Spider's LAB — Recent Files" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    prompt_prefix = "  SCAN > ",
                    selection_caret = "  ",
                    entry_prefix = "  ",
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.5,
                        },
                        width = 0.87,
                        height = 0.80,
                    },
                    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    file_ignore_patterns = {
                        "node_modules", ".git/", "%.lock", "__pycache__",
                        "%.o", "%.a", "%.out", "%.class", "%.pdf", "%.mkv",
                        "%.mp4", "%.zip", "%.tar", "%.gz",
                    },
                },
            })
            pcall(telescope.load_extension, "fzf")
        end,
    },

    -- ══════════════════════════════════════════════════════════════
    --  LSP — Language Server Protocol. The machine talks back.
    --  // This is where the editor becomes alive.
    --  // Diagnostics. Completions. Go-to-definition.
    --  // The code KNOWS what it is. And it tells you.
    --  // Neovim 0.11+ native vim.lsp.config API. No wrappers.
    -- ══════════════════════════════════════════════════════════════
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- // Diagnostic display — minimal, inline, no noise.
            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●",
                    spacing = 4,
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN]  = " ",
                        [vim.diagnostic.severity.HINT]  = " ",
                        [vim.diagnostic.severity.INFO]  = " ",
                    },
                },
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = {
                    border = "single",
                    source = true,
                    header = "Spider's LAB — Diagnostics",
                },
            })

            -- // On-attach keymaps — these activate when an LSP connects.
            -- // Think of it as the server handshake. Link established.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("SpidersLabLsp", { clear = true }),
                callback = function(ev)
                    local map = function(keys, func, desc)
                        vim.keymap.set("n", keys, func, {
                            buffer = ev.buf,
                            desc = "LSP: " .. desc,
                        })
                    end

                    map("<leader>gd", vim.lsp.buf.definition, "Go-To-Definition")
                    map("<leader>gD", vim.lsp.buf.declaration, "Go-To-Declaration")
                    map("<leader>gi", vim.lsp.buf.implementation, "Go-To-Implementation")
                    map("<leader>gr", vim.lsp.buf.references, "References")
                    map("<leader>gt", vim.lsp.buf.type_definition, "Type Definition")
                    map("K", vim.lsp.buf.hover, "Hover Documentation")
                    map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
                    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("<leader>ds", vim.lsp.buf.document_symbol, "Document Symbols")
                    map("<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
                    map("<leader>df", vim.diagnostic.open_float, "Diagnostic Float")
                    map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
                    map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
                end,
            })

            -- // Server configs — Neovim 0.11 native vim.lsp.config API.
            -- // No more lspconfig.server.setup(). Direct. Clean. Fast.
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        workspace = {
                            checkThirdParty = false,
                            library = { vim.env.VIMRUNTIME },
                        },
                        diagnostics = { globals = { "vim" } },
                        telemetry = { enable = false },
                    },
                },
            })

            vim.lsp.config("pyright", {})
            vim.lsp.config("clangd", {})
            vim.lsp.config("bashls", {})
            vim.lsp.config("rust_analyzer", {})

            -- // Enable all configured servers. The handshake begins.
            vim.lsp.enable({ "lua_ls", "pyright", "clangd", "bashls", "rust_analyzer" })
        end,
    },

    -- ══════════════════════════════════════════════════════════════
    --  LUALINE — the diagnostic HUD. Your neural status bar.
    --  // Minimalist. Functional. "Link Established" when LSP is live.
    --  // Mode indicator glows Spider-Red. Because we always know
    --  // what mode we're in. ALWAYS.
    -- ══════════════════════════════════════════════════════════════
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            -- // Custom Spider-Neon theme for lualine.
            -- // Transparent backgrounds. Cyan data. Red accents.
            local spider_lualine = {
                normal = {
                    a = { fg = "#191724", bg = "#FC199A", gui = "bold" },
                    b = { fg = "#61E2FF", bg = "#241B30" },
                    c = { fg = "#6B5F7B", bg = "NONE" },
                },
                insert = {
                    a = { fg = "#191724", bg = "#61E2FF", gui = "bold" },
                },
                visual = {
                    a = { fg = "#191724", bg = "#AF6DF9", gui = "bold" },
                },
                replace = {
                    a = { fg = "#191724", bg = "#FFCC00", gui = "bold" },
                },
                command = {
                    a = { fg = "#191724", bg = "#72F1B8", gui = "bold" },
                },
                inactive = {
                    a = { fg = "#6B5F7B", bg = "#241B30" },
                    b = { fg = "#6B5F7B", bg = "#241B30" },
                    c = { fg = "#3B3455", bg = "NONE" },
                },
            }

            require("lualine").setup({
                options = {
                    theme = spider_lualine,
                    component_separators = { left = "│", right = "│" },
                    section_separators = { left = "", right = "" },
                    globalstatus = true,
                    disabled_filetypes = { statusline = { "alpha" } },
                },
                sections = {
                    lualine_a = {
                        {
                            "mode",
                            fmt = function(str)
                                local modes = {
                                    NORMAL  = " NRM",
                                    INSERT  = " INS",
                                    VISUAL  = " VIS",
                                    ["V-LINE"] = " V-L",
                                    ["V-BLOCK"] = " V-B",
                                    REPLACE = " REP",
                                    COMMAND = " CMD",
                                    TERMINAL = " TRM",
                                }
                                return modes[str] or str
                            end,
                        },
                    },
                    lualine_b = {
                        { "branch", icon = "" },
                        {
                            "diff",
                            symbols = { added = " ", modified = " ", removed = " " },
                            diff_color = {
                                added    = { fg = "#72F1B8" },
                                modified = { fg = "#FFCC00" },
                                removed  = { fg = "#FC199A" },
                            },
                        },
                    },
                    lualine_c = {
                        { "filename", path = 1, symbols = { modified = " ●", readonly = " " } },
                        {
                            "diagnostics",
                            sources = { "nvim_diagnostic" },
                            symbols = { error = " ", warn = " ", info = " ", hint = " " },
                            diagnostics_color = {
                                error = { fg = "#FE5EB5" },
                                warn  = { fg = "#FFCC00" },
                                info  = { fg = "#61E2FF" },
                                hint  = { fg = "#72F1B8" },
                            },
                        },
                    },
                    lualine_x = {
                        {
                            -- // LSP link status — the handshake indicator.
                            function()
                                local clients = vim.lsp.get_clients({ bufnr = 0 })
                                if #clients == 0 then
                                    return "  No Link"
                                end
                                local names = {}
                                for _, client in ipairs(clients) do
                                    table.insert(names, client.name)
                                end
                                return "  Link Established [" .. table.concat(names, ", ") .. "]"
                            end,
                            color = function()
                                local clients = vim.lsp.get_clients({ bufnr = 0 })
                                if #clients > 0 then
                                    return { fg = "#61E2FF" }
                                end
                                return { fg = "#6B5F7B" }
                            end,
                        },
                    },
                    lualine_y = {
                        { "encoding", fmt = string.upper },
                        { "fileformat", symbols = { unix = "LF", dos = "CRLF", mac = "CR" } },
                        "filetype",
                    },
                    lualine_z = {
                        { "location" },
                        { "progress" },
                    },
                },
            })
        end,
    },

    -- ══════════════════════════════════════════════════════════════
    --  ALPHA — the splash screen. The boot sequence.
    --  // When you open nvim with no file, this is what you see.
    --  // Spider's LAB v1.0. The web awaits.
    -- ══════════════════════════════════════════════════════════════
    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- // The Spider's Web — ASCII art header.
            -- // Every hacker needs a calling card.
            dashboard.section.header.val = {
                [[                                                      ]],
                [[          ╲       ╱       ╲       ╱                   ]],
                [[           ╲     ╱   ╲ ╱   ╲     ╱                    ]],
                [[            ╲   ╱   ──╳──   ╲   ╱                     ]],
                [[             ╲ ╱   ╱   ╲   ╲ ╱                        ]],
                [[         ─────╳───╱─────╲───╳─────                    ]],
                [[             ╱ ╲   ╲   ╱   ╱ ╲                        ]],
                [[            ╱   ╲   ──╳──   ╱   ╲                     ]],
                [[           ╱     ╲   ╱ ╲   ╱     ╲                    ]],
                [[          ╱       ╲ ╱     ╲ ╱       ╲                  ]],
                [[                                                      ]],
                [[   ███████╗██████╗ ██╗██████╗ ███████╗██████╗ ██╗███████╗]],
                [[   ██╔════╝██╔══██╗██║██╔══██╗██╔════╝██╔══██╗╚═╝██╔════╝]],
                [[   ███████╗██████╔╝██║██║  ██║█████╗  ██████╔╝   ███████╗]],
                [[   ╚════██║██╔═══╝ ██║██║  ██║██╔══╝  ██╔══██╗   ╚════██║]],
                [[   ███████║██║     ██║██████╔╝███████╗██║  ██║   ███████║]],
                [[   ╚══════╝╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚══════╝]],
                [[              L    A    B        v 1 . 0              ]],
                [[                                                      ]],
                [[      "Hack the Planet." — Zero Cool, 1995           ]],
                [[                                                      ]],
            }

            -- // Dashboard actions — quick shortcuts.
            dashboard.section.buttons.val = {
                dashboard.button("f", "  SCAN FILESYSTEM",    ":Telescope find_files<CR>"),
                dashboard.button("g", "  GREP THE WEB",       ":Telescope live_grep<CR>"),
                dashboard.button("r", "  RECENT TARGETS",     ":Telescope oldfiles<CR>"),
                dashboard.button("n", "  NEW BUFFER",         ":ene <BAR> startinsert<CR>"),
                dashboard.button("c", "  EDIT CONFIG",        ":e $MYVIMRC<CR>"),
                dashboard.button("q", "  DISCONNECT",         ":qa<CR>"),
            }

            -- // Footer — the closing transmission.
            dashboard.section.footer.val = {
                "",
                "Spider's LAB — Neovim HUD Online",
                "// Secure channel. No logs. No traces.",
            }

            -- // Apply highlight groups.
            dashboard.section.header.opts.hl = "AlphaHeader"
            dashboard.section.buttons.opts.hl = "AlphaButtons"
            dashboard.section.footer.opts.hl = "AlphaFooter"

            -- // Button highlight.
            for _, button in ipairs(dashboard.section.buttons.val) do
                button.opts.hl = "AlphaButtons"
                button.opts.hl_shortcut = "AlphaShortcut"
            end

            alpha.setup(dashboard.opts)
        end,
    },

    -- ══════════════════════════════════════════════════════════════
    --  QUALITY OF LIFE — small tools, big impact
    -- ══════════════════════════════════════════════════════════════

    -- // Web devicons — file type icons everywhere.
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- // Indent guides — see the structure.
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = { char = "│", highlight = "IblIndent" },
            scope = { enabled = true, show_start = false, highlight = "IblScope" },
        },
        config = function(_, opts)
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2D2250" })
            vim.api.nvim_set_hl(0, "IblScope",  { fg = "#FC199A" })
            require("ibl").setup(opts)
        end,
    },

    -- // Autopairs — brackets close themselves. One less thing to think about.
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = { check_ts = true },
    },

    -- // Gen.nvim — local AI via Ollama inside the editor.
    --  Select code → <leader>ai to chat, or use specific commands.
    {
        "David-Kunz/gen.nvim",
        cmd = "Gen",
        keys = {
            { "<leader>ai", ":Gen<CR>",                mode = { "n", "v" }, desc = "Spider-Sense — AI Menu" },
            { "<leader>ae", ":Gen Explain_Code<CR>",   mode = "v",          desc = "Spider-Sense — Explain" },
            { "<leader>at", ":Gen Generate_Tests<CR>",  mode = "v",          desc = "Spider-Sense — Tests" },
            { "<leader>ao", ":Gen Optimize_Code<CR>",   mode = "v",          desc = "Spider-Sense — Optimize" },
            { "<leader>ar", ":Gen Review_Code<CR>",     mode = "v",          desc = "Spider-Sense — Review" },
            { "<leader>af", ":Gen Fix_Code<CR>",        mode = "v",          desc = "Spider-Sense — Fix" },
        },
        opts = {
            model = "llama3.2",
            display_mode = "split",
            show_model = true,
        },
    },

    -- // Gitsigns — git status in the gutter.
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
            },
        },
    },

}, {
    -- // Lazy.nvim UI config — Spider-Red borders. Obviously.
    ui = {
        border = "single",
        icons = {
            cmd = " ",
            config = " ",
            event = " ",
            ft = " ",
            init = " ",
            keys = " ",
            plugin = " ",
            runtime = " ",
            source = " ",
            start = " ",
            task = " ",
        },
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "matchit", "matchparen", "netrwPlugin",
                "tarPlugin", "tohtml", "tutor", "zipPlugin",
            },
        },
    },
})


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 5: APPLY COLORSCHEME                                           ║
-- ║  // The theme is loaded. Now we paint the world.                       ║
-- ║  // This runs AFTER plugins load so our highlights stick.              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

apply_spider_neon()

-- // Re-apply after ColorScheme event in case anything overrides us.
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        if vim.g.colors_name ~= "spider-neon" then
            apply_spider_neon()
        end
    end,
})


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 6: KEYBINDINGS — MUSCLE MEMORY                                 ║
-- ║  // These are your reflexes. Train them.                               ║
-- ║  // Space is the gateway. Every combo starts there.                    ║
-- ║  // "Type cookie, you idiot." — Cereal Killer                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local map = vim.keymap.set

-- // Break Reality — save everything and get out. Clean exit.
map("n", "<leader>br", "<cmd>wa<cr><cmd>qa<cr>",
    { desc = "Spider's LAB — Break Reality (save all & exit)" })

-- // Quick save — because losing work is for amateurs.
map("n", "<leader>w", "<cmd>w<cr>",
    { desc = "Spider's LAB — Write buffer" })

-- // Quit — close the current window. Clean exit.
map("n", "<leader>q", "<cmd>q<cr>",
    { desc = "Spider's LAB — Quit window" })

-- // Clear search highlighting — disappear the evidence.
map("n", "<Esc>", "<cmd>nohlsearch<cr>",
    { desc = "Clear search highlights" })

-- // Better window navigation — Ctrl+hjkl.
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- // Buffer navigation — Tab and Shift+Tab.
map("n", "<Tab>",   "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- // Better indenting — stay in visual mode.
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- // Move selected lines — Alt+j/k.
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- // Diagnostic float — see what's wrong without looking away.
map("n", "<leader>e", vim.diagnostic.open_float,
    { desc = "Spider's LAB — Show diagnostic" })

-- // Terminal — open a terminal split. Another pane, another dimension.
map("n", "<leader>tt", "<cmd>split<cr><cmd>terminal<cr>i",
    { desc = "Spider's LAB — Terminal split" })

-- // Escape terminal mode — get back to normal.
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 7: AUTOCOMMANDS — BACKGROUND PROCESSES                         ║
-- ║  // The spider's web runs on autopilot.                                ║
-- ║  // These fire in the background. Invisible. Efficient.                ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local augroup = vim.api.nvim_create_augroup("SpidersLab", { clear = true })

-- // Highlight yanked text — visual feedback. You see what you took.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- // Remove trailing whitespace on save — clean code only.
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = "*",
    callback = function()
        local save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
    end,
})

-- // Return to last edit position — memory is a weapon.
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- // Auto-resize splits when terminal is resized.
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  END OF TRANSMISSION                                                   ║
-- ║                                                                        ║
-- ║  // Zero Cool, signing off.                                            ║
-- ║  // The web is spun. The HUD is online.                                ║
-- ║  // Remember: "Mess with the best, die like the rest."                ║
-- ║  //                                                                    ║
-- ║  // Spider's LAB v1.0 — Neovim Configuration                          ║
-- ║  // Hack the planet.                                                   ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
