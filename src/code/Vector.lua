Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
    return setmetatable(
        {
            x = x or 0,
            y = y or 0
        },
        Vector
    )
end

setmetatable(Vector, { __call = function (t, ...) return Vector.new(...) end })

function Vector.__add(t1, t2)
    return Vector(t1.x + t2.x, t1.y + t2.y)
end

function Vector.__mul(a, t)
    return Vector(a * t.x, a * t.y)
end

function Vector:__unm()
    return (-1) * self
end

function Vector.__sub(t1, t2)
    return t1 + (-t2)
end

function Vector.__div(t, a)
    return (1/a) * t
end

function Vector.__eq(t1, t2)
    return t1.x == t2.x and t1.y == t2.y
end

function Vector.__tostring(t)
    return "Vector(" .. t.x .. ", " .. t.y .. ")"
end

function Vector:translate(t)
    return self + t
end

function Vector:rotateCounterclockwiseAround(origin, numberOfRotations)
    return (self - origin):rotateCounterclockwise(numberOfRotations) + origin
end

function Vector:rotateCounterclockwise(numberOfRotations)
    local n = (numberOfRotations or 1) % 4
    if(n == 0) then
        return self
    elseif(n == 1) then
        return self:rotateOnceCounterclockwise()
    elseif(n == 2) then
        return self:rotateTwice()
    elseif(n == 3) then
        return self:rotateOnceClockwise()
    else
        error("Vector:rotateCounterclockwise: bad argument: " .. tostring(n), 2)
    end
end

function Vector:rotateTwice()
    return Vector(-self.x, -self.y)
end

function Vector:rotateOnceCounterclockwise()
    return Vector(-self.y, self.x)
end

function Vector:rotateOnceClockwise()
    return Vector(self.y, -self.x)
end

directions =
    {
        left = Vector(-1, 0),
        up = Vector(0, -1),
        right = Vector(1, 0),
        down = Vector(0, 1)
    }
