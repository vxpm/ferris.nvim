local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Opens the parent module of the current module.
local function open_parent_module()
    if not error.ensure_ra() then return end

    lsp.experimental_request("parentModule", vim.lsp.util.make_position_params(0, lsp.offset_encoding()),
        function(response)
            if response.result == nil then
                if response.error == nil then
                    error.raise("no answer from rust-analyzer for parent module")
                    return
                end

                error.raise_lsp_error("error opening parent module", response.error)
                return
            end

            -- HACK: workaround for https://github.com/neovim/neovim/issues/19492
            local position = response.result
            if vim.tbl_isarray(position) then
                position = position[1]
            end

            vim.lsp.util.jump_to_location(position, "utf-8", true)
        end)
end

return open_parent_module
