Stage = Object:extend()

function Stage:new()
    self.area = Area()
    self.timer = Timer()
   
    local function process()
        timer.cancel('process every')
        for i = 1, 10 do
            timer:after(i*0.25, function()
                self.area:addGameObject('Circle', random(0, 800), random(0, 600))
            end)
        end
        
        timer:after(2.5, function()
            timer:every('process every', random(0.5, 1), function()
                table.remove(self.area.game_objects, love.math.random(1, #self.area.game_objects))
                if #self.area.game_objects == 0 then
                    process()
                end
            end)
        end)
    end
    
    process()
end
function Stage:update(dt)
    self.area:update(dt)
    self.timer:update(dt)
end

function Stage:draw()
    self.area:draw()
end