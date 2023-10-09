local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Reloads the workspace of a project.
local function reload_workspace()
    if not error.ensure_ra() then return end
    lsp.request("reloadWorkspace", nil, function(_) end)
end

return reload_workspace
