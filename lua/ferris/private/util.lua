local M = {}

---Returns an iterator over the lines of a string.
---@param s string # A string
---@return fun(): string # An iterator over the lines of the string
function M.iter_lines(s)
    if s:sub(-1) ~= "\n" then s = s .. "\n" end
    return s:gmatch("(.-)\n")
end

---Turns some string into an array of lines.
---@param s string # The string
---@return string[] # An array of lines
function M.string_to_line_array(s)
    local lines = {}
    for line in M.iter_lines(s) do
        table.insert(lines, line)
    end

    return lines
end

---Returns the maximum key in a table with numeric keys.
---@param tbl table<number, any>
---@return number
function M.max_key(tbl)
    local max = 0
    for i, _ in pairs(tbl) do
        if i > max then
            max = i
        end
    end

    return max
end

return M
