PolygonRoom = Object:extend()

function PolygonRoom:new()
end

function PolygonRoom:update(dt)
end

function PolygonRoom:draw()
    love.graphics.polygon('fill', 400, 300 - 50, 400 + 50, 300, 400, 300 + 50, 400 - 50, 300)
end