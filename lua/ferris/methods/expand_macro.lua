local view = require("ferris.private.view")
local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Expands the macro under the current cursor position.
local function expand_macro()
    if not error.ensure_ra() then return end

    lsp.request("expandMacro", vim.lsp.util.make_position_params(), function(response)
        if response.result == nil then
            if response.error == nil then
                error.raise(
                    "no answer from rust-analyzer for macro expansion in given cursor position")
                return
            end

            error.raise_lsp_error("error expanding macro", response.error)
            return
        end

        ---@type string
        local name = response.result.name
        ---@type string
        local expansion = response.result.expansion

        view.open("macro", expansion, "Recursive expansion of the " .. name .. " macro")
    end)
end

return expand_macro
