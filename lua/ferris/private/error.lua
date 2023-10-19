local M = {}
local lsp = require("ferris.private.ra_lsp")

---Raises an error with the given message
---@param message string # The error message
function M.raise(message)
    vim.notify("ferris.nvim - " .. message, vim.log.levels.ERROR)
end

---@param condition boolean # The condition expected to be false
---@param message string # The error message in case it isn't
---@return boolean # Returns the condition
function M.on(condition, message)
    if not condition then
        M.raise(message)
    end

    return condition
end

---Ensures Rust-Analyzer is attached to the current buffer and
---raise an error if not
---@return boolean # Whether Rust-Analyzer is attached or not
function M.ensure_ra()
    if not lsp.current_buf_has_ra() then
        M.raise("no rust-analyzer instance found attached to current buffer")
        return false
    end

    return true
end

---Raises an error with a message based on the given LspResponseError
---@param context string # The context of the error
---@param err LspResponseError # The LSP error the message is based on
function M.raise_lsp_error(context, err)
    M.raise(context .. ": [" .. (tostring(err.code) or "unknown code") .. "] " .. (err.description or "(no description)"))
end

return M
