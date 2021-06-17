function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function random(min, max)
    if not max then -- if max is nil then it means only one value was passed in
        return love.math.random()*min
    else
        if min > max then min, max = max, min end -- values can come in any order
        return love.math.random()*(max - min) + min
    end
end

-- Returns distance between two coordinates --
function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2))
end

-- printAll(1, 2, 3)  --
function printAll(...)
    local args = {...}
    for _, arg in ipairs(args) do
        print(arg)
    end
end

-- printText('This', " is", " a test") --
function printText(...)
    local args = {...}
    local string = ''
    for _, arg in ipairs(args) do 
        string = string .. arg
    end
    print(string)
end