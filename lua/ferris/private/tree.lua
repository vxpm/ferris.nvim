local M = {}

---@class Node
---@field value any
---@field children Node[]
M.Node = {}
M.Node.__index = M.Node

---Creates a new Node.
---@param value any # The value of the Node.
---@param children Node[]? # The children of the Node.
---@return Node
function M.Node.new(value, children)
    local o = setmetatable({}, M.Node)
    o.value = value
    o.children = children or {}
    return o
end

---Add a new child to this node's children.
---@param child Node # The child node to add as children to this node.
function M.Node:push(child)
    table.insert(self.children, child)
end

return M
