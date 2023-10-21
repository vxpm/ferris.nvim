local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")
local config = require("ferris.private.config")

---Opens the Cargo.toml file of a project.
local function open_documentation()
    if not error.ensure_ra() then return end

    lsp.experimental_request("externalDocs", vim.lsp.util.make_position_params(0, lsp.offset_encoding()),
        function(response)
            if response.result == nil then
                if response.error == nil then
                    error.raise("no answer from rust-analyzer for external documentation")
                    return
                end

                error.raise_lsp_error("error opening external documentation", response.error)
                return
            end

            local url = response.result["local"] or response.result.web or response.result

            if type(config.opts.url_handler) ~= "string" then
                config.opts.url_handler(url)
                return
            end

            local cmd_str = ":! " .. config.opts.url_handler .. " " .. url .. " &"
            local cmd = vim.api.nvim_parse_cmd(cmd_str, {})
            cmd.mods.silent = true

            vim.api.nvim_cmd(cmd, {})
        end)
end

return open_documentation
