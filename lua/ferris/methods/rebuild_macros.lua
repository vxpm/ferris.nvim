local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Rebuilds procedural macros in a project.
local function rebuild_macros()
    if not error.ensure_ra() then return end
    lsp.request("rebuildProcMacros", nil, function(_) end)
end

return rebuild_macros
