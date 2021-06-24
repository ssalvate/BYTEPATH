HP = GameObject:extend()

function HP:new(area, x, y, opts)
    HP.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = random(48, gh - 48)

    self.w, self.h = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-24, 24))
end

function HP:update(dt)
    HP.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0) 
end

function HP:draw()
    love.graphics.setColor(hp_color)
    love.graphics.rectangle('fill', self.x - self.w/2, self.y - 2, self.w, 4)
    love.graphics.rectangle('fill', self.x - 2, self.y - self.h/2, 4, self.h)
    love.graphics.setColor(default_color)
    love.graphics.circle('line', self.x, self.y, self.w)
    love.graphics.setColor(255, 255, 255)
end

function HP:destroy()
    HP.super.destroy(self)
end

function HP:die()
    self.dead = true
    self.area:addGameObject('InfoText', self.x + table.random({-1, 1})*self.w, self.y + table.random({-1, 1})*self.h, {color = hp_color, text = '+HP'})
    self.area:addGameObject('BoostEffect', self.x, self.y, {color = hp_color, w = self.w, h = self.h})
    --self.area:addGameObject('ShapeEffect', self.x, self.y, {color = default_color, w = math.floor(self.w/3), shape = 'circle'})
    --self.area:addGameObject('ShapeEffect2', self.x, self.y, {color = hp_color, w = self.w/2, shape = 'health'})
end