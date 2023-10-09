local M = {}

local default = {
    create_commands = true,
    url_handler = "xdg-open",
}

M.opts = vim.deepcopy(default)

---Updates the plugin configuration.
---@param opts table # The configuration table
function M.update(opts)
    M.opts = vim.tbl_deep_extend("force", {}, default, opts or {})
end

return M
