local view = require("ferris.private.view")
local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Shows the MIR of the function in the cursor position.
local function view_mir()
    if not error.ensure_ra() then return end

    lsp.request("viewMir", vim.lsp.util.make_position_params(), function(response)
        if response.result == nil or response.result == "Not inside a function body" then
            if response.error == nil then
                local suffix = (response.result and
                    "(not inside a function body)") or ""
                error.raise(
                    "no answer from rust-analyzer for MIR in given cursor position " .. suffix)
                return
            end

            error.raise_lsp_error("error viewing MIR", response.error)
            return
        end

        view.open("mir", response.result, "MIR View")
    end)
end

return view_mir
