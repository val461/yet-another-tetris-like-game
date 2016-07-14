require("code.Grid")
require("code.Vector")
require("code.Colors")
require("code.Tetrominoes")

--[[ TODO’s
    print time elapsed from the beginning of the game
    high scores
        shown at pause or when game is over
        possibility to reset
    4D-tetris (fork from current)
]]

resetBestScoreAtTheEnd = true
randomizedColors = true

canFallTimerDurationUpperBound = 1.2
scoreDecreasesBy = 4

timers =
    {
        canMoveDown = { duration = 0.11 },
        canMove = { duration = 0.11 },
        canRotate = { duration = 0.15 },
        megafall = { duration = 0.3 },
        scoreDecreases = { duration = 1 },
        canFall = {}    -- this one is initialized at runtime
    }

local function newTetromino()
    return Tetrominoes:newInstanceOfRandomModel(grid, randomizedColors)
end

local function pointsForCompletedRows(n)
    return math.ceil(n * 100 * (1.2^n))
end

local function getCanFallTimerDuration()
    local newDuration = 200 / (score + 1)
    if newDuration < canFallTimerDurationUpperBound then
        return newDuration
    else
        return canFallTimerDurationUpperBound
    end
end

local function resetTimers()
    for _, v in pairs(timers) do
        v.value = 0
    end
    timers.canFall.duration = getCanFallTimerDuration()
end

local function initGame()
        score = 0
        if resetBestScoreAtTheEnd or not bestScore then
            bestScore = 0
        end
        paused = false
        gameover = false
        resetTimers()
        currentTetromino = newTetromino()
end

local function freeze()
    currentTetromino:freezeInto(grid.frozenSquares)
    local newPoints = pointsForCompletedRows(grid.frozenSquares:removeCompletedRows())
    if newPoints > 0 then
        score = score + newPoints
        if score > bestScore then
            bestScore = score
        end
        timers.canFall.duration = getCanFallTimerDuration()
    end
    currentTetromino = newTetromino()
    if currentTetromino:collidesWith(grid.frozenSquares) then
        currentTetromino = nil
        gameover = true
    end
end

local function freezeOrFall()
    if not currentTetromino:move(directions.down, grid.frozenSquares) then
        freeze()
    end
end

function love.load(args)
    grid = Grid()
    initGame()

    messageHeight = 30
    messageLocation = Vector(grid.outerPosition.x + grid.outerWidth + 30, grid.outerPosition.y + 260)
    fontColor = colors.purple

    love.graphics.setBackgroundColor(colors.green)
end

function love.keyreleased(key)
    if key == 'escape' then
        love.event.quit()
        return
    elseif key == 'r' then
        grid.frozenSquares:erase()
        initGame()
        --~ return
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

    if timers.canFall.value < timers.canFall.duration then
        timers.canFall.value = timers.canFall.value + dt
    else
        freezeOrFall()
        timers.canFall.value = 0
        if gameover then
            return
        end
    end

    if timers.canMove.value < timers.canMove.duration then
        timers.canMove.value = timers.canMove.value + dt
    else
        if love.keyboard.isDown('left','a', 'kp1', 'kp4', 'kp7') then
            currentTetromino:move(directions.left, grid.frozenSquares)
            timers.canMove.value = 0
        end

        if love.keyboard.isDown('right','d', 'kp3', 'kp6', 'kp9') then
            currentTetromino:move(directions.right, grid.frozenSquares)
            timers.canMove.value = 0
        end
    end

    if timers.canMoveDown.value < timers.canMoveDown.duration then
        timers.canMoveDown.value = timers.canMoveDown.value + dt
    else
        if love.keyboard.isDown('down','s', 'kp1', 'kp2', 'kp3', 'kp5') then
            freezeOrFall()
            timers.canMoveDown.value = 0
            if gameover then
                return
            end
        end
    end

    if timers.canRotate.value < timers.canRotate.duration then
        timers.canRotate.value = timers.canRotate.value + dt
    else
        if love.keyboard.isDown('up','w', 'kp5', 'kp7', 'kp8', 'kp9') then
            currentTetromino:rotate(grid.frozenSquares)
            timers.canRotate.value = 0
        end
    end

    if timers.megafall.value < timers.megafall.duration then
        timers.megafall.value = timers.megafall.value + dt
    else
        if love.keyboard.isDown('space', 'return', 'kp0') then   -- fall all the way down
            while currentTetromino:canMove(directions.down, grid.frozenSquares) do
                currentTetromino:forceTranslation(directions.down)
            end
            freeze()
            timers.megafall.value = 0
            if gameover then
                return
            end
        end
    end

    if timers.scoreDecreases.value < timers.scoreDecreases.duration then
        timers.scoreDecreases.value = timers.scoreDecreases.value + dt
    elseif score > 0 then
        score = score - scoreDecreasesBy
        if score < 0 then
            score = 0
        end
        timers.scoreDecreases.value = 0
        timers.canFall.duration = getCanFallTimerDuration()
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

    messageNumber = 0

    printMessage(score)
    printMessage("best: " .. bestScore)
    --~ printMessage(timers.canFall.duration)  --DEBUGGING

    if gameover then
        printMessage("GAME OVER")
    end

    if paused then
        printMessage("PAUSED")
    end
end
