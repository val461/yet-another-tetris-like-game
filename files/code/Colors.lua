require("code.Tables")

colors =
    {
        gray   = {100, 100, 100},
        green  = {  0, 255,   0},
        blue   = {  0, 127, 255},
        purple = {255,   0, 255},
        red    = {255,   0,   0},
        orange = {255, 127,   0},
        yellow = {255, 255,   0},
        white  = {255, 255, 255}
    }

local unnamedColors = Tables.values(colors)-- no black on black, for the sake of visibility
colors.black = {0, 0, 0}

function randomColor()
    return unnamedColors[math.random(#unnamedColors)]
end
