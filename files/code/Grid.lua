require("code.Vector")
require("code.Square")
require("code.FrozenSquares")
require("code.Colors")

Grid = {}
Grid.__index = Grid

function Grid.new(position, nRows, nCols, bgColor, edgeColor, innerMargin)
    local t = {}
    t.innerMargin = innerMargin or 12
    t.outerPosition = position or Vector()
    t.position = t.outerPosition + Vector(t.innerMargin, t.innerMargin)
    t.frozenSquares = FrozenSquares(nRows, nCols, t)
    t.height = t.frozenSquares.nRows * Square.length + Square.halfGap
    t.width = t.frozenSquares.nCols * Square.length + Square.halfGap
    t.outerWidth = t.width + 2 * t.innerMargin
    t.outerHeight = t.height + 2 * t.innerMargin
    t.startingPosition = Vector(math.floor(t.frozenSquares.nCols / 2), 1)
    t.bgColor = bgColor or colors.black
    t.edgeColor = edgeColor or colors.gray
    return setmetatable(t, Grid)
end

setmetatable(Grid, { __call = function (t, ...) return Grid.new(...) end })

function Grid:draw()
    love.graphics.setColor(self.edgeColor)
    love.graphics.rectangle("fill", self.outerPosition.x, self.outerPosition.y, self.outerWidth, self.outerHeight)

    love.graphics.setColor(self.bgColor)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.width, self.height)

    self.frozenSquares:draw()
end
