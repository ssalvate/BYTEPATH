Circle = GameObject:extend()

function Circle:new(x, y, opts)
    Circle.super.new(self, x, y, opts)
    self.r = random(10, 50)
end

function Circle:update(dt)
    Circle.super.update(self, dt)
end

function Circle:draw()
    love.graphics.circle('fill', self.x, self.y, self.r)
end