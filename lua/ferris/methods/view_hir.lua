local view = require("ferris.private.view")
local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Shows the HIR of the function in the cursor position.
local function view_hir()
    if not error.ensure_ra() then return end

    lsp.request("viewHir", vim.lsp.util.make_position_params(), function(response)
        if response.result == nil or response.result == "Not inside a function body" then
            if response.error == nil then
                local suffix = ((response.result and
                    "(not inside a function body)") or "")
                error.raise(
                    "no answer from rust-analyzer for HIR in given cursor position " .. suffix)
                return
            end

            error.raise_lsp_error("error viewing HIR", response.error)
            return
        end

        view.open("hir", response.result, "HIR View")
    end)
end

return view_hir
