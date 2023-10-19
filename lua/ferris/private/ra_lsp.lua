local M = {}

---@class LspResponseError
---@field code integer # The error code.
---@field description string # A description of the error.
---@field data any? # Additional information.

---@alias _LspRequestId integer | string | nil

---@class LspResponse
---@field id _LspRequestId # The ID of the request (not sure what it means).
---@field result any? # The result of the request when successful.
---@field error LspResponseError? # The error of the request when unsuccessful.

---Tries to sends a LSP request to Rust-Analayzer.
---@param full_method string # The full LSP method of the request.
---@param params table? # Parameters of the request.
---@param handler fun(response: LspResponse?) # Handler to call after the request is completed.
local function inner_request(full_method, params, handler)
    ---@param responses table<integer, LspResponse?>
    local extract_first_response = function(responses)
        for _, response in ipairs(responses) do
            handler(response)
            return
        end
    end

    vim.lsp.buf_request_all(0, full_method, params, extract_first_response)
end

---Tries to sends a LSP request to Rust-Analayzer.
---@param method string # The LSP method of the request.
---@param params table? # Parameters of the request.
---@param handler fun(response: LspResponse?) # Handler to call after the request is completed.
function M.request(method, params, handler)
    inner_request("rust-analyzer/" .. method, params, handler)
end

---Tries to sends an experimental LSP request to Rust-Analayzer.
---@param method string # The experimental LSP method of the request.
---@param params table? # Parameters of the request.
---@param handler fun(response: LspResponse?) # Handler to call after the request is completed.
function M.experimental_request(method, params, handler)
    inner_request("experimental/" .. method, params, handler)
end

---Returns the client ID of Rust-Analyzer in the current buffer
---@return integer? # The client ID
function M.ra_client_id()
    local clients = {}
    local vim_version = vim.version()
    if vim_version.minor <= 9 then
        clients = vim.lsp.buf_get_clients()
    else
        clients = vim.lsp.get_clients({ bufnr = 0 })
    end

    for _, client in ipairs(clients) do
        if client.name == "rust_analyzer" then
            return client.id
        end
    end

    return nil
end

---Tests for the presence of Rust-Analyzer in the current buffer
---@return boolean
function M.current_buf_has_ra()
    return M.ra_client_id() ~= nil
end

return M
