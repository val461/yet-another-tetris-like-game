require("code.Grid")
require("code.Vector")
require("code.Colors")
require("code.Tetrominoes")

--[[ TODO’s
    score as mere reciprocal of canFallTimerDuration
    score decreases constantly (even when negative)
    print time elapsed from the beginning of the game
    high scores
        shown at pause or when game is over
        possibility to reset
    4D-tetris (fork from current)
]]

local function newTetromino()
    return Tetrominoes:newInstanceOfRandomModel(grid)
end

local function pointsForCompletedRows(n)
    return math.ceil(n * 100 * (1.2^n))
end

local function updateCanFallTimerDuration()
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
    end
end

local function freezeOrFall()
    if not currentTetromino:move(directions.down, grid.frozenSquares) then
        freeze()
    end
end

function love.load(args)
    score = 0
    paused = false
    gameover = false
    grid = Grid()
    currentTetromino = newTetromino()

    messageHeight = 30
    messageLocation = Vector(grid.outerPosition.x + grid.outerWidth + 60, grid.outerPosition.y + 260)
    fontColor = colors.purple

    updateCanFallTimerDuration()
    canMoveDownTimerDuration = 0.1
    canMoveTimerDuration = 0.13
    canRotateTimerDuration = 0.2
    megafallTimerDuration = 0.3

    canFallTimer = 0
    canMoveDownTimer = 0
    canMoveTimer = 0
    canRotateTimer = 0
    megafallTimer = 0

    love.graphics.setBackgroundColor(colors.green)
end

function love.keyreleased(key)
    if key == 'escape' then
        love.event.quit()
        return
    elseif key == 'r' then
        score = 0
        grid.frozenSquares:erase()
        currentTetromino = newTetromino()
        paused = false
        gameover = false
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
        if love.keyboard.isDown('left','a', 'kp1', 'kp4', 'kp7') then
            currentTetromino:move(directions.left, grid.frozenSquares)
            canMoveTimer = 0
        end

        if love.keyboard.isDown('right','d', 'kp3', 'kp6', 'kp9') then
            currentTetromino:move(directions.right, grid.frozenSquares)
            canMoveTimer = 0
        end
    end

    if canMoveDownTimer < canMoveDownTimerDuration then
        canMoveDownTimer = canMoveDownTimer + dt
    else
        if love.keyboard.isDown('down','s', 'kp1', 'kp2', 'kp3', 'kp5') then
            freezeOrFall()
            canMoveDownTimer = 0
            if gameover then
                return
            end
        end
    end

    if canRotateTimer < canRotateTimerDuration then
        canRotateTimer = canRotateTimer + dt
    else
        if love.keyboard.isDown('up','w', 'kp5', 'kp7', 'kp8', 'kp9') then
            currentTetromino:rotate(grid.frozenSquares)
            canRotateTimer = 0
        end
    end

    if megafallTimer < megafallTimerDuration then
        megafallTimer = megafallTimer + dt
    else
        if love.keyboard.isDown('space', 'return', 'kp0') then   -- fall all the way down
            while currentTetromino:canMove(directions.down, grid.frozenSquares) do
                currentTetromino:forceTranslation(directions.down)
            end
            freeze()
            megafallTimer = 0
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
    messageNumber = 0

    printMessage(score)

    if gameover then
        printMessage("GAME OVER")
    end

    if paused then
        printMessage("PAUSED")
    end
end
