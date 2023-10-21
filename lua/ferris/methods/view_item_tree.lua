local view = require("ferris.private.view")
local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Shows the item tree of the current document.
local function view_item_tree()
    if not error.ensure_ra() then return end

    lsp.request("viewItemTree", { textDocument = vim.lsp.util.make_text_document_params(0) }, function(response)
        if response.result == nil then
            if response.error == nil then
                error.raise(
                    "no answer from rust-analyzer for item tree in given document")
                return
            end

            error.raise_lsp_error("error viewing item tree", response.error)
            return
        end

        view.open("item_tree", response.result, "Item Tree")
    end)
end

return view_item_tree
