require("code.Vector")
require("code.Square")
require("code.Tetromino")
require("code.Tables")

FrozenSquares = {}
FrozenSquares.__index = FrozenSquares

local topRowIndex = 1

function FrozenSquares.new(nRows, nCols, grid)
    local row = {}

    for j = 1, nCols do
        table.insert(row, false)    -- set default value to false because nil cannot be stored in lua arrays
    end

    local t = 
        {
            nRows = (nRows or 12),
            nCols = (nCols or 20),
            grid = grid,
            squares = { row }
        }

    for i = 2, nRows do
        table.insert(t.squares, copy(row))
    end

    return setmetatable(t, FrozenSquares)
end

setmetatable(FrozenSquares, { __call = function (t, ...) return FrozenSquares.new(...) end })

function FrozenSquares:squareAt(position)
    return self.squares[position.y][position.x]
end

function FrozenSquares:setSquareAt(position, color)
    self.squares[position.y][position.x] = color
end

function FrozenSquares:add(position, color)
    self:setSquareAt(position, color or { 40, 40, 40 })
end

function FrozenSquares:invalidCoords(pos)
    return 1 > pos.x or pos.x > self.nCols
        or 1 > pos.y or pos.y > self.nRows
end

local function rowIsComplete(row)
    for _, sq in ipairs(row) do
        if not sq then
            return false
        end
    end
    return true
end

-- private
function FrozenSquares:indexOfSomeCompletedRow()
    for rowIndex, row in ipairs(self.squares) do
        if rowIsComplete(row) then
            return rowIndex
        end
    end
    return nil
end

-- private
function FrozenSquares:duplicateRow(rowIndex, newRowIndex)
    for columnIndex, sq in ipairs(self.squares[rowIndex]) do
        self.squares[newRowIndex][columnIndex] = sq
    end
end

-- private
function FrozenSquares:eraseRow(rowIndex)
    for columnIndex, _ in ipairs(self.squares[rowIndex]) do
        self.squares[rowIndex][columnIndex] = false
    end
end

function FrozenSquares:erase()
    for rowIndex, _ in ipairs(self.squares) do
        self:eraseRow(rowIndex)
    end
end

-- private
function FrozenSquares:removeRow(rowIndex)
    local down, up = directions.down.y, directions.up.y
    for i = rowIndex + up, topRowIndex, up do
        self:duplicateRow(i, i + down)
    end
    self:eraseRow(topRowIndex)
end

function FrozenSquares:removeCompletedRows()
    local rowIndex = self:indexOfSomeCompletedRow()
    local n = 0
    while rowIndex do
        self:removeRow(rowIndex)
        n = n + 1
        rowIndex = self:indexOfSomeCompletedRow()
    end
    return n
end

local function drawSquare(location, color)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", location.x + Square.halfGap, location.y + Square.halfGap, Square.visibleLength, Square.visibleLength)
end

function FrozenSquares:draw()
    for i, row in ipairs(self.squares) do
        for j, color in ipairs(row) do
            if color then
                drawSquare(self.grid.position + Square.length * Vector(j - 1, i - 1), color)
            end
        end
    end
end
