TestPlayer = GameObject:extend()

function TestPlayer:new(area, x, y, opts)
    TestPlayer.super.new(self, area, x, y, opts)

    self.x, self.y = x, y
    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    ship_size = self.w /2
    rotation_speed = 1.66
    self.r = -math.pi/2 --Angle in radians
    self.rv = rotation_speed*math.pi --Rotation
    self.v = 0 
    self.max_v = 100
    self.base_v = 0
    
    --  Acceleration  --
    self.a = 5 --  amount of Acceleration
    self.boosting = false
    self.thrust = {x =0, y =0} -- Keep track of vector

    --  Ships  --
    self.ship = 'Fighter'
    DefineShipVisuals(self)

    input:bind('f5', function() self:die() end)
    input:bind('s', function() self.shoot(self) end)
end

function DefineShipVisuals(self)
    self.polygons = {}

    if self.ship == 'Fighter' then
        self.polygons[1] = {
            self.w, 0, -- 1
            self.w/2, -self.w/2, -- 2
            -self.w/2, -self.w/2, -- 3
            -self.w, 0, -- 4
            -self.w/2, self.w/2, -- 5
            self.w/2, self.w/2, -- 6
        }
        
        self.polygons[2] = {
            self.w/2, -self.w/2, -- 7
            0, -self.w, -- 8
            -self.w - self.w/2, -self.w, -- 9
            -3*self.w/4, -self.w/4, -- 10
            -self.w/2, -self.w/2, -- 11
        }
        
        self.polygons[3] = {
            self.w/2, self.w/2, -- 12
            -self.w/2, self.w/2, -- 13
            -3*self.w/4, self.w/4, -- 14
            -self.w - self.w/2, self.w, -- 15
            0, self.w, -- 16
        }
    elseif self.ship == 'Striker' then
        self.polygons[1] = {
            self.w, 0,
            self.w/2, -self.w/2,
            -self.w/2, -self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2,
            self.w/2, self.w/2,
        }

        self.polygons[2] = {
            0, self.w/2,
            -self.w/4, self.w,
            0, self.w + self.w/2,
            self.w, self.w,
            0, 2*self.w,
            -self.w/2, self.w + self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2,
        }

        self.polygons[3] = {
            0, -self.w/2,
            -self.w/4, -self.w,
            0, -self.w - self.w/2,
            self.w, -self.w,
            0, -2*self.w,
            -self.w/2, -self.w - self.w/2,
            -self.w, 0,
            -self.w/2, -self.w/2,
        }
    elseif self.ship == 'Test' then
        self.polygons[1] = {
            self.w/2, 0,
            -self.w/2, -self.w/2,
            -self.w, 0,
            -self.w/2, self.w/2
        }
    end
end

function createTrail(self)
    self.trail_color = skill_point_color 
   -- self.timer:every(0.01, function()
        if self.ship == 'Fighter' then
            self.area:addGameObject('TrailParticle', 
            self.x - 0.9*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 0.9*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 0.9*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 0.9*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
        elseif self.ship == 'Striker' then
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r - math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r - math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
            self.area:addGameObject('TrailParticle', 
            self.x - 1.0*self.w*math.cos(self.r) + 0.2*self.w*math.cos(self.r + math.pi/2), 
            self.y - 1.0*self.w*math.sin(self.r) + 0.2*self.w*math.sin(self.r + math.pi/2), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
        elseif self.ship == 'Test' then
            self.area:addGameObject('TrailParticle', 
            self.x - self.w*math.cos(self.r), self.y - self.h*math.sin(self.r), 
            {parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color}) 
        end
    --end)
end

function TestPlayer:update(dt)
    TestPlayer.super.update(self, dt)

    if input:down('up') then
        self.thrust.x = math.floor(self.thrust.x +  self.a * math.cos(self.r))
        self.thrust.y = math.floor(self.thrust.y +  self.a * math.sin(self.r))
        self.boosting = true
    else
        self.boosting = false
    end
    
    -- Collision -- 
    if self.x - self.w/2 < 0  then self:die() end
    if self.y - self.w/2 < 0  then self:die() end
    if self.x + self.w/2 > gw then self:die() end
    if self.y + self.w/2 > gh  then self:die() end
    
    -- Movement  --
    if input:down('left') then self.r = self.r - self.rv*dt end
    if input:down('right') then self.r = self.r + self.rv*dt end
    
    if self.boosting then createTrail(self) end

    -- Positional Mvm occurs on collider, then applies back to this player obj  --
    self.collider:setPosition(self.x + self.thrust.x * dt, self.y + self.thrust.y* dt)
end

function TestPlayer:shoot(self)
    local d = 1.2*self.w

    self.area:addGameObject('ShootEffect', self.x + d*math.cos(self.r), 
    self.y + d*math.sin(self.r), {player = self, d = d})

    self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), 
    self.y + 1.5*d*math.sin(self.r), {r = self.r, v = 100})
end

function TestPlayer:draw()
    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(default_color)
    for _, polygon in ipairs(self.polygons) do
        local points = fn.map(polygon, function(v, k) 
            if k % 2 == 1 then 
                    return self.x + v + random(-1, 1) -- - 2*self.w
            else 
                    return self.y + v + random(-1, 1) 
            end 
            end)
        love.graphics.polygon('line', points)
    end
    love.graphics.pop()

    if MODE < 2 then
        loc = self.x .. ", " .. self.y
        love.graphics.print("Loc: "..tostring(loc), 375, 5 )
    end

    if MODE == MODES.DEBUG then -- Collider and aim line --
        love.graphics.circle('line', self.x, self.y, self.w)
        love.graphics.line(self.x, self.y, self.x + 2*self.w*math.cos(self.r), self.y + 2*self.w*math.sin(self.r))
    end
end

function TestPlayer:die()
    self.dead = true 
    flash(4)
    camera:shake(6, 60, 0.4)
    slow(0.15, 1)
    for i = 1, love.math.random(8, 12) do 
    	self.area:addGameObject('ExplodeParticle', self.x, self.y) 
    end
end

function TestPlayer:shoot()
    local d = 1.2*self.w

    self.area:addGameObject('ShootEffect', self.x + d*math.cos(self.r), 
    self.y + d*math.sin(self.r), {player = self, d = d})

    self.area:addGameObject('Projectile', self.x + 1.5*d*math.cos(self.r), 
    self.y + 1.5*d*math.sin(self.r), {r = self.r, v = 100})

end

function TestPlayer:destroy()
    TestPlayer.super.destroy(self)
end