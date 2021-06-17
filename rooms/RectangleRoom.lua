RectangleRoom = Object:extend()

function RectangleRoom:new()
end

function RectangleRoom:update(dt)
end

function RectangleRoom:draw()
    love.graphics.rectangle('fill', 400 - 100/2, 300 - 50/2, 100, 50)
end