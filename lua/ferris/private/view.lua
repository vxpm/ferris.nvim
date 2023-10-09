local M = {}
local util = require("ferris.private.util")
local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")

---Adds a header to the given line array.
---@param lines string[] # The line array
---@param header string # The header
---@return string[] # The same array of lines, but with the header added
local function add_header(lines, header)
    local lines = vim.deepcopy(lines)

    local header = "// " .. header
    table.insert(lines, 1, "")
    table.insert(lines, 1, "// " .. string.rep("=", string.len(header) - 3))
    table.insert(lines, 1, header)

    return lines
end

---@type table<string, integer>
VIEWS = {}

---Opens the given view in a split.
---@param tag string # The tag of the view. Views with the same tag
--- will override each other and reuse the same window (if already open).
---@param view string | string[] # The contents of the view.
---@param header string # The header of the view.
---@param filetype string? # The filetype of the view. Optional.
function M.open(tag, view, header, filetype)
    if VIEWS[tag] == nil then
        -- create new buffer for view
        VIEWS[tag] = vim.api.nvim_create_buf(false, true)

        -- create new window for view
        vim.cmd('vsplit')
        local win_id = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win_id, VIEWS[tag])

        -- when the window is closed, delete the view buffer
        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(win_id),
            callback = function(args)
                VIEWS[tag] = nil
                return true
            end
        })
    end

    -- set filetype of buffer for syntax highlighting
    local vim_version = vim.version()
    if vim_version.minor <= 9 then
        vim.api.nvim_buf_set_option(VIEWS[tag], "filetype", "rust")
    else
        vim.api.nvim_set_option_value("filetype", filetype or "rust", { buf = VIEWS[tag] })
    end

    -- set the contents of the buffer
    if type(view) == "string" then
        local view_lines = util.string_to_line_array(view)
        vim.api.nvim_buf_set_lines(VIEWS[tag], 0, -1, false, add_header(view_lines, header))
    else
        vim.api.nvim_buf_set_lines(VIEWS[tag], 0, -1, false, add_header(view, header))
    end
end

return M
