local view = require("ferris.private.view")
local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Shows the syntax tree of the selection or code in the cursor position.
local function view_syntax_tree()
    if not error.ensure_ra() then return end

    lsp.request("syntaxTree", vim.lsp.util.make_given_range_params(nil, nil, 0, lsp.offset_encoding()),
        function(response)
            if response.result == nil then
                if response.error == nil then
                    error.raise(
                        "no answer from rust-analyzer for syntax tree in given cursor position")
                    return
                end

                error.raise_lsp_error("error viewing syntax tree", response.error)
                return
            end

            view.open("syntax_tree", response.result, "Syntax Tree View")
        end)
end

return view_syntax_tree
