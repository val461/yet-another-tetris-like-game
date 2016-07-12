require("code.Grid")
require("code.Vector")
require("code.Colors")
require("code.Tetrominoes")
require("code.Strings")
--~ require("code.Square")
--~ require("code.Tetromino")
--~ require("code.FrozenSquares")

--[[ TODO
    4D-tetris (fork)
]]

local function newTetromino()
    return Tetrominoes:newInstanceOfRandomModel(grid)
end

local function pointsForCompletedRows(n)
    return math.ceil(n * 100 * (1.2^n))
end

--~ local function updateObjective()
    --~ if score > 0 then
        --~ local factor = 10 ^ (#tostring(score) - 1)
        --~ objective = factor * math.ceil(score / factor)
    --~ else
        --~ objective = 100
    --~ end
--~ end

local function updateCanFallTimerDuration()
    --~ canFallTimerDuration = 0.9^level
    canFallTimerDuration = 0.9^(score / 400)
end

local function freeze()
    currentTetromino:freezeInto(grid.frozenSquares)
    local newPoints = pointsForCompletedRows(grid.frozenSquares:removeCompletedRows())
    if newPoints > 0 then
        score = score + newPoints
        updateCanFallTimerDuration()
    end
    currentTetromino = newTetromino()
    if currentTetromino:collidesWith(grid.frozenSquares) then
        currentTetromino = nil
        gameover = true
    --~ elseif score > objective then
        --~ level = level + 1
        --~ updateObjective()
        --~ updateCanFallTimerDuration()
    end
end

local function freezeOrFall()
    if not currentTetromino:move(directions.down, grid.frozenSquares) then
        freeze()
    end
end

paused = false
gameover = false
grid = Grid(Vector(10, 10), 20, 14)
currentTetromino = newTetromino()

--~ level = 1
score = 0
--~ updateObjective()

messageHeight = 40
messageLocation = Vector(grid.outerPosition.x + grid.outerWidth + 60, messageHeight * 3)
--~ prefixes = { "level", "score", "objective" }
fontColor = colors.purple

updateCanFallTimerDuration()
canFallTimer = 0

canRotateTimerDuration = 0.2
canMoveTimerDuration = 0.1
canMoveTimer = 0

function love.load(arg)
    love.graphics.setBackgroundColor(70, 236, 22)
    love.graphics.setColor(40, 40, 40)
end

function love.keyreleased(key)
    if key == 'escape' then
        love.event.quit()
        return
    elseif key == 'n' then
        --~ if level > 1 then
            --~ level = level - 1
            --~ updateCanFallTimerDuration()
        --~ end
        score = 0
        --~ updateObjective()
        grid.frozenSquares:erase()
        currentTetromino = newTetromino()
        gameover = false
        return
    end

    if gameover or paused then
        return
    end

    canMoveTimer = canRotateTimerDuration

    if key == 'space' then   -- fall all the way down
        while currentTetromino:canMove(directions.down, grid.frozenSquares) do
            currentTetromino:forceTranslation(directions.down)
        end
        freeze()
	end
end

function love.keypressed(key)
    if key == 'tab' then
        paused = not paused
	end
end

function love.update(dt)
    if paused or gameover then
        return
    end

    if canFallTimer < canFallTimerDuration then
        canFallTimer = canFallTimer + dt
    else
        freezeOrFall()
        canFallTimer = 0
        if gameover then
            return
        end
    end

    if canMoveTimer < canMoveTimerDuration then
        canMoveTimer = canMoveTimer + dt
    else
        if canMoveTimer < canRotateTimerDuration then
            canMoveTimer = canMoveTimer + dt
        elseif love.keyboard.isDown('up','w') then
            currentTetromino:rotate(grid.frozenSquares)
            canMoveTimer = 0
        end
        if love.keyboard.isDown('left','a') then
            currentTetromino:move(directions.left, grid.frozenSquares)
            canMoveTimer = 0
        end
        if love.keyboard.isDown('right','d') then
            currentTetromino:move(directions.right, grid.frozenSquares)
            canMoveTimer = 0
        end
        if love.keyboard.isDown('down','s') then
            freezeOrFall()
            canMoveTimer = 0
            if gameover then
                return
            end
        end
    end
end

local function printMessage(message)
    love.graphics.print(message, messageLocation.x, messageLocation.y + messageNumber * messageHeight)
    messageNumber = messageNumber + 1
end

function love.draw()
    grid:draw()
    if currentTetromino then
        currentTetromino:draw()
    end
    love.graphics.setColor(fontColor)

    --~ local paddedMessages = pad(prefixes, toStrings{level, score, objective})
    --~ local paddedMessages = pad(prefixes, {tostring(score)})
    messageNumber = 0
    --~ printMessage(paddedMessages.level)
    --~ printMessage(paddedMessages.objective)
    printMessage("score " .. score)

    if gameover then
        printMessage("GAME OVER")
    end

    if paused then
        printMessage("PAUSED")
    end
end
