require("code.Tables")
require("code.Vector")
require("code.Tetromino")
require("code.Colors")
math.randomseed(os.time())

Tetrominoes = { models = {} }

function Tetrominoes:newInstanceOfModel(index, grid)
    local new = Tetromino(
        copy(self.models[index].squares),
        self.models[index].canRotate,
        grid,
        self.models[index].color
        --~ randomColor()
    )
    new:randomRotation()
    new:forceTranslation(grid.startingPosition - new:highestPosition())
    return new
end

function Tetrominoes:newInstanceOfRandomModel(grid)
    return self:newInstanceOfModel(math.random(#Tetrominoes.models), grid)
end

local function add(squares, direction)
    table.insert(squares, Square(squares[#squares].position + direction))
end

-- I
local squares = { Square() }
add(squares, directions.right)
add(squares, directions.right)
add(squares, directions.right)
table.insert(Tetrominoes.models, { squares = squares, color = colors.purple })

-- O
squares = { Square() }
add(squares, directions.right)
add(squares, directions.down)
add(squares, directions.left)
table.insert(Tetrominoes.models, { squares = squares, color = colors.white, canRotate = false })

-- T
squares = { Square() }
add(squares, directions.right)
add(squares, directions.down)
add(squares, directions.up + directions.right)
table.insert(Tetrominoes.models, { squares = squares, color = colors.blue })

-- J
squares = { Square() }
add(squares, directions.right)
add(squares, directions.right)
add(squares, directions.down)
table.insert(Tetrominoes.models, { squares = squares, color = colors.red })

-- L
squares = { Square() }
add(squares, directions.left)
add(squares, directions.left)
add(squares, directions.down)
table.insert(Tetrominoes.models, { squares = squares, color = colors.green })

-- S
squares = { Square() }
add(squares, directions.left)
add(squares, directions.down)
add(squares, directions.left)
table.insert(Tetrominoes.models, { squares = squares, color = colors.yellow })

-- Z
squares = { Square() }
add(squares, directions.right)
add(squares, directions.down)
add(squares, directions.right)
table.insert(Tetrominoes.models, { squares = squares, color = colors.gray })
