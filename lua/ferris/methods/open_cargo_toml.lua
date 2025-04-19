local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Opens the Cargo.toml file of a project.
local function open_cargo_toml()
    if not error.ensure_ra() then return end

    lsp.experimental_request("openCargoToml", { textDocument = vim.lsp.util.make_text_document_params(0) },
        function(response)
            if response.result == nil then
                if response.error == nil then
                    error.raise("no answer from rust-analyzer for Cargo.toml")
                    return
                end

                error.raise_lsp_error("error opening Cargo.toml", response.error)
                return
            end

            if vim.fn.has "nvim-0.11" == 1 then
              vim.lsp.util.show_document(response.result, "utf-8", { reuse_win = true, focus = true })
            else
              vim.lsp.util.jump_to_location(response.result, "utf-8", true)
            end
        end)
end

return open_cargo_toml
