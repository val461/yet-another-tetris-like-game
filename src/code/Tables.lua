Tables = {}

function copy(a)    -- deep copy for values but shallow copy for keys and metatables
    if type(a) == "table" then
        local result = {}
        for k, v in pairs(a) do
            result[k] = copy(v)
        end
        return setmetatable(result, getmetatable(a))
    else
        return a
    end
end

function Tables.emptyArray(width, height)
    local result = {}
    if height and 1 <= height then
        for i = 1, width do
            table.insert(result, Tables.emptyArray(height))
        end
    else
        for i = 1, width do
            table.insert(result, false)    -- set default value to false because nil cannot be stored in lua arrays
        end
    end
    return result
end

function pa(t, printKeys)  -- print an array shallowly
    local str = "{ "
    for i, v in ipairs(t) do
        if (printKeys) then
            str = str .. "[" .. i .. "] = "
        end
        str = str .. tostring(v) .. ", "
    end
    if #str > 2 then
        str = str:sub(1, -3)   -- remove last comma
    end
    return str .. " }"
end

function pt(t)  -- print a table shallowly
    local str = "{ "
    for k, v in pairs(t) do
        if (type(k) == "string") then
            if (k:find("^[_%a]+[_%w]*$")) then  -- valid variable name
                str = str .. k
            else
                str = str .. "[\"" .. k .. "\"]"
            end
        else
            str = str .. "[" .. tostring(k) .. "]"
        end
        str = str .. " = " .. tostring(v) .. ", "
    end
    if #str > 2 then
        str = str:sub(1, -3)   -- remove last comma
    end
    return str .. " }"
end

function Tables.keys(t)
    local result = {}
    for k, _ in pairs(self) do
        table.insert(result, k)
    end
    return result
end

function Tables.values(t)
    local result = {}
    for _, v in pairs(t) do
        table.insert(result, v)
    end
    return result
end

function Tables.extremum(t, compare)
    local result = nil
    for _, v in pairs(t) do
        if not result or compare(v, result) then
            result = v
        end
    end
    return result
end

function Tables.min(t)
    return Tables.extremum(t, function (new, acc) return new < acc end)
end

function Tables.max(t)
    return Tables.extremum(t, function (new, acc) return new > acc end)
end

function map(f, t)
    local result = {}
    for k, v in ipairs(t) do
        result[k] = f(v)
    end
    return result
end
