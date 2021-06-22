Sandbox = Object:extend()

function Sandbox:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.timer = Timer()
    
    self.main_canvas = love.graphics.newCanvas(gw, gh)
    
    self.player = self.area:addGameObject('TestPlayer', gw/2, gh/2)
end

function Sandbox:update(dt)
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)

    self.area:update(dt)
    self.timer:update(dt)
end

function Sandbox:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        camera:attach(0, 0, gw, gh)
        self.area:draw()
        camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

function Sandbox:destroy()
    self.area:destroy()
    self.area = nil
end