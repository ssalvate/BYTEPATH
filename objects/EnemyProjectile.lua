EnemyProjectile = GameObject:extend()

function EnemyProjectile:new(area, x, y, opts)
    EnemyProjectile.super.new(self, area, x, y, opts)

    self.s = opts.s or 2.5
    self.v = opts.v or 200


    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))
    self.collider:setCollisionClass('EnemyProjectile')
    
    self.damage = 10
end

function EnemyProjectile:update(dt)
    EnemyProjectile.super.update(self, dt)
    self.collider:setLinearVelocity(self.v*math.cos(self.r), self.v*math.sin(self.r))

    if self.collider:enter('Player') then
        local collision_data = self.collider:getEnterCollisionData('Player')
        local object = collision_data.collider:getObject()
        if object then
            object:hit(self.damage)
            self:die()
        end
    end

    if self.collider:enter('Projectile') then
        local collision_data = self.collider:getEnterCollisionData('Projectile')
        local object = collision_data.collider:getObject()

        if object then
            object:die()
            self:die()
        end
    end

    -- Off Screen --
    if self.x - self.s < 0 then self:die() end
    if self.y - self.s < 0 then self:die() end
    if self.x + self.s > gw then self:die() end
    if self.y + self.s > gh then self:die() end
end

function EnemyProjectile:draw()
    pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo()) 
    love.graphics.setLineWidth(self.s - self.s/4)
    love.graphics.setColor(hp_color)
    love.graphics.line(self.x - 2*self.s, self.y, self.x, self.y)
    love.graphics.setColor(hp_color)
    love.graphics.line(self.x, self.y, self.x + 2*self.s, self.y)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
end

function EnemyProjectile:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = hp_color, w = 3*self.s})
end

function EnemyProjectile:destroy()
    EnemyProjectile.super.destroy(self)
end