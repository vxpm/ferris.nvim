local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Join lines in selection or current cursor position.
local function join_lines(r)
    if not error.ensure_ra() then return end

    local buf = vim.api.nvim_get_current_buf()
    local params = vim.lsp.util.make_given_range_params(nil, nil, buf, lsp.offset_encoding());
    params.ranges = { params.range }
    params.range = nil

    lsp.experimental_request("joinLines", params, function(response)
        if response.result == nil then
            if response.error == nil then
                error.raise(
                    "no answer from rust-analyzer for joining lines in given cursor position")
                return
            end

            error.raise_lsp_error("error joining lines", response.error)
            return
        end

        vim.lsp.util.apply_text_edits(response.result, buf, lsp.offset_encoding())
    end)
end

return join_lines
