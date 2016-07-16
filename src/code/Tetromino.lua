require("code.Tables")
require("code.Vector")
require("code.Square")
require("code.Colors")

centerIndex = 2

Tetromino = {}
Tetromino.__index = Tetromino

function Tetromino.new(squares, canRotate, grid, color)
    if canRotate == nil then
        canRotate = true
    end
    return setmetatable(
        {
            squares = squares,
            canRotate = canRotate,
            grid = grid,
            color = color or colors.gray
        },
        Tetromino
    )
end

setmetatable(Tetromino, { __call = function (t, ...) return Tetromino.new(...) end })

-- private
function Tetromino:forEachSquare(f)
    for _, sq in ipairs(self.squares) do
        f(sq)
    end
end

-- private
function Tetromino:map(f)
    local result = {}
    for _, sq in ipairs(self.squares) do
        table.insert(result, f(sq))
    end
    return result
end

-- private
function Tetromino:someSquare(p)
    for _, sq in ipairs(self.squares) do
        if p(sq) then
            return true
        end
    end
    return false
end

-- private
function Tetromino:allSquares(p)
    for _, sq in ipairs(self.squares) do
        if not p(sq) then
            return false
        end
    end
    return true
end

function Tetromino:isBlocked(direction, frozenSquares)
    local function isBlocked(sq)
        return sq:isBlocked(direction, frozenSquares)
    end
    return self:someSquare(isBlocked)
end

function Tetromino:canMove(direction, frozenSquares)
    return not self:isBlocked(direction, frozenSquares)
end

function Tetromino:move(direction, frozenSquares)
    if currentTetromino:isBlocked(direction, frozenSquares) then
        return false
    else
        currentTetromino:forceTranslation(direction)
        return true
    end
end

function Tetromino:draw()
    love.graphics.setColor(self.color)

    local function drawSquare(sq)
        sq:draw(self.grid)
    end

    self:forEachSquare(drawSquare)
end

-- private
function Tetromino:forceTranslation(vector)
    local function translateSquare(sq)
        sq:forceTranslation(vector)
    end
    self:forEachSquare(translateSquare)
end

-- private
function Tetromino:highestPosition()
    local function compare(new, acc)
        return new.position.y < acc.position.y
    end
    return Tables.extremum(self.squares, compare).position
end

-- private
function Tetromino:center()
    return self.squares[centerIndex]:getCenter()
end

-- private
function Tetromino:forceRotation(n)
    local tetrominoCenter = self:center()
    local function rotateSquare(sq)
        local posRelativeToTetrominoCenter = sq:getCenter() - tetrominoCenter
        posRelativeToTetrominoCenter:rotateCounterclockwise(n)
        sq:setCenter(posRelativeToTetrominoCenter + tetrominoCenter)
    end
    self:forEachSquare(rotateSquare)
end

function Tetromino:randomRotation()
    self:forceRotation(math.random(0, 3))
end

function Tetromino:rotate(frozenSquares)
    if self.canRotate then
        local new = Tetromino(copy(self.squares))
        new:forceRotation()
        if new:collidesWith(frozenSquares) then
            return false
        else
            self.squares = new.squares
            return true
        end
    else
        return false
    end
end

function Tetromino:collidesWith(frozenSquares)
    function collides(sq)
        return frozenSquares:invalidCoords(sq.position) or frozenSquares:squareAt(sq.position)
    end
    return self:someSquare(collides)
end

function Tetromino:freezeInto(frozenSquares)
    function freeze(sq)
        frozenSquares:add(sq.position, self.color)
    end
    self:forEachSquare(freeze)
end
