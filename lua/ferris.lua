local M = {}

function M.setup(opts)
    local config = require("ferris.private.config")
    config.update(opts)

    if config.opts.create_commands then
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("ferris_commands", { clear = true }),
            desc = "Add Ferris user commands to rust_analyzer buffers",
            callback = function(args)
                if vim.lsp.get_client_by_id(args.data.client_id).name == "rust_analyzer" then
                    M.create_commands(args.buf)
                end
            end,
        })
    end
end

--- Create user commands for the methods provided by Ferris
---@param bufnr? integer Optional buffer number to only add the commands to a given buffer. Default behavior is to create global user commands
function M.create_commands(bufnr)
    local function cmd(name, module, opts)
        if bufnr then
            vim.api.nvim_buf_create_user_command(bufnr, name, require(module), opts or {})
        else
            vim.api.nvim_create_user_command(name, require(module), opts or {})
        end
    end

    cmd("FerrisExpandMacro", "ferris.methods.expand_macro")
    cmd("FerrisJoinLines", "ferris.methods.join_lines", { range = true })
    cmd("FerrisViewHIR", "ferris.methods.view_hir")
    cmd("FerrisViewMIR", "ferris.methods.view_mir")
    cmd("FerrisViewMemoryLayout", "ferris.methods.view_memory_layout")
    cmd("FerrisViewSyntaxTree", "ferris.methods.view_syntax_tree", { range = true })
    cmd("FerrisViewItemTree", "ferris.methods.view_item_tree")
    cmd("FerrisOpenCargoToml", "ferris.methods.open_cargo_toml")
    cmd("FerrisOpenParentModule", "ferris.methods.open_parent_module")
    cmd("FerrisOpenDocumentation", "ferris.methods.open_documentation")
    cmd("FerrisReloadWorkspace", "ferris.methods.reload_workspace")
    cmd("FerrisRebuildMacros", "ferris.methods.rebuild_macros")
end

return M
