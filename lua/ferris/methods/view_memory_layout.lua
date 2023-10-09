local view = require("ferris.private.view")
local lsp = require("ferris.private.ra_lsp")
local error = require("ferris.private.error")
local tree = require("ferris.private.tree")
local util = require("ferris.private.util")

-- NOTE: code here is a little messy and unoptimal, but it works, so that's fine!

---@class RANode
---@field alignment integer # The alignment of this node's field.
---@field childrenLen integer # The amount of children this node has.
---@field childrenStart integer # The start index of the children list of this node.
---@field itemName string # The name of this node's field.
---@field offset integer # The offset of this node's field relative to it's parent.
---@field parentIdx integer # The index of the parent of this node.
---@field size integer # The size of this node's field.
---@field typename string # The type name of this node's field.

---@class Field
---@field name string
---@field type string
---@field size integer
---@field offset integer
---@field alignment integer
local Field = {}
Field.__index = Field

---@return Field
function Field.new(fields)
    local o = fields
    setmetatable(o, Field)
    return o
end

---Returns the header of the field.
---@return string # The header.
function Field:header()
    return self.name .. ': ' .. self.type
end

---Returns the body of the field.
---@return string # The body.
function Field:body()
    return 'size: ' .. tostring(self.size) .. ', align: ' .. tostring(self.alignment)
end

---Returns the required cell width of the field.
---@return integer
function Field:cell_width()
    local header_width = string.len(self:header())
    local body_width = string.len(self:body())
    return math.max(header_width, body_width)
end

---Turns a RANode list into a Node tree.
---@param list RANode[] # The RANode list returned by Rust-Analyzer.
local function to_tree(list)
    ---Turns the RANode at the given index in the list into a Field node.
    ---@param index integer # The RANode index in the list
    ---@param list RANode[] # The list of RANodes
    ---@return Node # The Field node
    local function field_at_idx_node(index, list)
        local ra_node = list[index]

        local field = Field.new({
            name = ra_node.itemName,
            type = ra_node.typename,
            size = ra_node.size,
            offset = ra_node.offset,
            alignment = ra_node.alignment
        })

        local node = tree.Node.new(field)
        for other_index, other_ra_node in ipairs(list) do
            if other_ra_node.parentIdx == index - 1 then
                local other_node = field_at_idx_node(other_index, list)
                node:push(other_node)
            end
        end

        return node
    end

    return field_at_idx_node(1, list)
end

---@class FieldGrid : { [integer]: table<integer, Field> }
local FieldGrid = {}
FieldGrid.__index = FieldGrid

---@return FieldGrid
function FieldGrid.new()
    local o = {}
    setmetatable(o, FieldGrid)
    return o
end

---Returns the width of the given column, in characters
---@param index integer # The column index
---@return integer
function FieldGrid:column_width(index)
    ---@type integer
    local max = 0
    for _, row in pairs(self) do
        if row[index] ~= nil then
            local cell_width = row[index]:cell_width()
            if cell_width > max then
                max = cell_width
            end
        end
    end

    return max
end

---Returns an array of the offsets contained in this grid, sorted
---@return integer[]
function FieldGrid:offsets()
    local offsets = {}
    for i, _ in pairs(self) do
        table.insert(offsets, i)
    end

    table.sort(offsets)
    return offsets
end

---Returns the width of this grid in cells
---@return integer
function FieldGrid:width()
    local max = 0
    for _, row in pairs(self) do
        local width = util.max_key(row)
        if width > max then
            max = width
        end
    end

    return max
end

---Turns a tree into a field grid
---@param tree Node
---@return FieldGrid
local function to_grid(tree)
    local grid = FieldGrid.new()

    ---@param tree Node
    ---@param parent_offset integer
    ---@param depth integer
    local function traverse(tree, parent_offset, depth)
        ---@type Field
        local field = tree.value

        -- ignore zero-sized types as they don't actually
        -- contribute to the layout of the type and might
        -- clash with non-zsts at the same offset
        if field.size == 0 then
            return
        end

        -- Field offsets are relative to their parent,
        -- so make them relative to root
        local root_offset = parent_offset + field.offset

        grid[root_offset] = grid[root_offset] or {}
        grid[root_offset][depth] = field

        local children = tree.children
        for _, child in pairs(children) do
            traverse(child, root_offset, depth + 1)
        end
    end

    traverse(tree, 0, 1)
    return grid
end

---Returns the length of the offset column
---@return integer
function FieldGrid:offset_column_len()
    local offsets = self:offsets()
    local largest_offset = offsets[#offsets]
    local largest_offset_string = tostring(largest_offset)
    local largest_offset_len = string.len(largest_offset_string)
    return largest_offset_len + 1
end

---Renders the first divisor
---@return string # The first divisor
function FieldGrid:render_first_divisor()
    local offsets = self:offsets()
    local first_divisor = tostring(0) .. string.rep(" ", self:offset_column_len() - 1) .. "┼"
    for column_index = 1, self:width() do
        if self[offsets[1]][column_index] == nil then
            break
        end

        first_divisor = first_divisor .. string.rep("─", self:column_width(column_index) + 2) .. "┼"
    end

    return first_divisor
end

---Returns the offset for the given row
---@param row integer # The row index
---@return integer # The offset of the given row
function FieldGrid:get_offset(row)
    local offsets = self:offsets()
    return offsets[row]
end

---Renders the divisor of the given row
---@param row integer # The row index
---@return string # The divisor string
function FieldGrid:render_divisor(row)
    local row_offset = self:get_offset(row)
    local row_elements = self[row_offset]
    local next_row_offset = self:get_offset(row + 1)
    local next_row_elements = self[next_row_offset] or {}

    -- if there is a next row, display its offset in this divisor
    local offset_string = ""
    if next_row_offset ~= nil then
        offset_string = tostring(next_row_offset)
    end

    local offset_string_padding = self:offset_column_len() - string.len(offset_string)
    local divisor = offset_string .. string.rep(" ", offset_string_padding) .. "┼"

    -- render the divisor of each cell
    for column = 1, self:width() do
        -- if we are in the last row and past it's end, we can stop early
        local last_row_and_past_end = next_row_offset == nil and column > util.max_key(row_elements)
        if last_row_and_past_end then
            break
        end

        -- if there's a field below or we are not past the next row's
        -- maximum index, then draw a divisor
        local past_row_max = column > util.max_key(row_elements)
        local past_next_row_max = column > util.max_key(next_row_elements)
        if past_row_max and past_next_row_max then
            break
        end

        local cell_has_field = row_elements[column] ~= nil
        local next_row_cell_has_field = next_row_elements[column] ~= nil
        if next_row_offset == nil or next_row_cell_has_field or (cell_has_field and past_next_row_max) then
            divisor = divisor .. string.rep("─", self:column_width(column) + 2) .. "┼"
        else
            divisor = divisor .. string.rep(" ", self:column_width(column) + 2) .. "┼"
        end
    end

    return divisor
end

---Renders the cell with the given position
---@param row integer # The row index
---@param col integer # The column index
---@return { header: string, body: string }
function FieldGrid:render_cell(row, col)
    local row_offset = self:get_offset(row)
    local row_elements = self[row_offset]
    local cell_element = row_elements[col]
    local last_column = util.max_key(row_elements)
    local column_width = self:column_width(col)

    local result = { header = "", body = "" }
    if col > last_column then
        return result
    end

    local barrier = " │ "
    if cell_element == nil then
        result.header = string.rep(" ", column_width) .. barrier
        result.body = string.rep(" ", column_width) .. barrier
    else
        local header = cell_element:header()
        local header_padding = column_width - string.len(header)
        local body = cell_element:body()
        local body_padding = column_width - string.len(body)

        result.header = header .. string.rep(" ", header_padding) .. barrier
        result.body = body .. string.rep(" ", body_padding) .. barrier
    end

    return result
end

---Renders the row with the given index
---@param row integer # The row index
---@return { header: string, body: string }
function FieldGrid:render_row(row)
    local row_offset = self:get_offset(row)
    local row_elements = self[row_offset]

    local row_headers = string.rep(" ", self:offset_column_len()) .. "│ "
    local row_bodies = string.rep(" ", self:offset_column_len()) .. "│ "

    -- render each cell of the row
    for column = 1, self:width() do
        local result = self:render_cell(row, column)
        row_headers = row_headers .. result.header
        row_bodies = row_bodies .. result.body
    end

    return { header = row_headers, body = row_bodies }
end

---Renders this FieldGrid into a line array
---@return string[]
function FieldGrid:render()
    local lines = {}

    -- render the first divisor
    local first_divisor = self:render_first_divisor()
    table.insert(lines, first_divisor)

    -- render each row
    local rows_len = #self:offsets()
    for row = 1, rows_len do
        local result = self:render_row(row)
        local divisor = self:render_divisor(row)

        table.insert(lines, result.header)
        table.insert(lines, result.body)
        table.insert(lines, divisor)
    end

    return lines
end

local function view_memory_layout()
    if not error.ensure_ra() then return end

    lsp.request("viewRecursiveMemoryLayout", vim.lsp.util.make_position_params(), function(response)
        if response.result == nil then
            if response.error == nil then
                error.raise("no answer from rust-analyzer for memory layout in given cursor position")
                return
            end

            error.raise_lsp_error("error viewing memory layout", response.error)
        end

        ---@type RANode[]
        local list = response.result.nodes
        local tree = to_tree(list)
        local grid = to_grid(tree)
        view.open("memory_layout", grid:render(), "Memory Layout of the " .. tree.value.type .. " type")
    end)
end

return view_memory_layout
