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

---Tries to sends a LSP request to Rust-Analyzer.
---@param full_method string # The full LSP method of the request.
---@param params table? # Parameters of the request.
---@param handler fun(response: LspResponse?) # Handler to call after the request is completed.
local function inner_request(full_method, params, handler)
    ---@param responses table<integer, LspResponse?>
    local extract_response = function(responses)
        local rust_analyzer_response = responses[M.ra_client_id()]

        -- If one of the responses comes from rust-analyzer - prefer it.
        if rust_analyzer_response ~= nil then
            handler(rust_analyzer_response)
            return
        end

        -- Otherwise, just pick any response. Don't use ipairs, because it
        -- won't work if there are nil responses in the middle of the list.
        for _, response in pairs(responses) do
            handler(response)
            return
        end
    end

    vim.lsp.buf_request_all(0, full_method, params, extract_response)
end

---Tries to sends a LSP request to Rust-Analyzer.
---@param method string # The LSP method of the request.
---@param params table? # Parameters of the request.
---@param handler fun(response: LspResponse?) # Handler to call after the request is completed.
function M.request(method, params, handler)
    inner_request("rust-analyzer/" .. method, params, handler)
end

---Tries to sends an experimental LSP request to Rust-Analyzer.
---@param method string # The experimental LSP method of the request.
---@param params table? # Parameters of the request.
---@param handler fun(response: LspResponse?) # Handler to call after the request is completed.
function M.experimental_request(method, params, handler)
    inner_request("experimental/" .. method, params, handler)
end

---Returns whether a client is Rust-Analyzer or not.
---@param client vim.lsp.Client
---@return boolean
function M.client_is_ra(client)
    -- Test by server info if available, otherwise just check for the client name.
    return (client.server_info and client.server_info.name == "rust-analyzer")
        or (client.name == "rust-analyzer" or client.name == "rust_analyzer")
end

---Returns the client ID of Rust-Analyzer in the given buffer.
---@param bufnr integer? # The buffer number or nil for current
---@return integer? # The client ID or nil if RA is not found
function M.ra_client_id(bufnr)
    ---@diagnostic disable-next-line:redefined-local
    local bufnr = bufnr or 0
    local clients = {}
    if vim.version().minor <= 9 then
        ---@diagnostic disable-next-line:deprecated It's ok - we've checked!
        clients = vim.lsp.buf_get_clients(bufnr)
    else
        clients = vim.lsp.get_clients({ bufnr = bufnr })
    end

    for _, client in pairs(clients) do
        if M.client_is_ra(client) then
            return client.id
        end
    end

    return nil
end

---Returns Rust-Analyzer's client offset encoding. If no client is found in the
---current buffer, returns "utf-16".
---@param bufnr integer? # The buffer number or nil for current
---@return string
function M.offset_encoding(bufnr)
    local ra_id = M.ra_client_id(bufnr)
    if ra_id == nil then
        return "utf-16"
    end

    local ra = vim.lsp.get_client_by_id(ra_id)
    ---@cast ra -nil

    return ra.offset_encoding
end

---Tests for the presence of Rust-Analyzer in the current buffer
---@return boolean
function M.current_buf_has_ra()
    return M.ra_client_id() ~= nil
end

return M
