local M = {}

function M.setup(opts)
    local config = require("ferris.private.config")
    config.update(opts)

    if config.opts.create_commands then
        local function cmd(name, file)
            vim.api.nvim_create_user_command(name, require(file), {})
        end

        cmd("FerrisExpandMacro", "ferris.methods.expand_macro")
        cmd("FerrisViewHIR", "ferris.methods.view_hir")
        cmd("FerrisViewMIR", "ferris.methods.view_mir")
        cmd("FerrisViewMemoryLayout", "ferris.methods.view_memory_layout")
        cmd("FerrisOpenCargoToml", "ferris.methods.open_cargo_toml")
        cmd("FerrisOpenParentModule", "ferris.methods.open_parent_module")
        cmd("FerrisOpenDocumentation", "ferris.methods.open_documentation")
        cmd("FerrisReloadWorkspace", "ferris.methods.reload_workspace")
        cmd("FerrisRebuildMacros", "ferris.methods.rebuild_macros")
    end
end

return M
