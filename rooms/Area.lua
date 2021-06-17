Area = Object:extend()

function Area:new(room)
    self.room = room
    self.game_objects = {}
end

-- Returns list of closest objects to object_type
function Area:getClosestObject(x, y, radius, object_types)
    local objects = self:queryCircleArea(x, y, radius, object_types)
    table.sort(objects, function(a, b)
        local da = distance(x, y, a.x, a.y)
        local db = distance(x, y, b.x, b.y)
        return da < db
    end)
    return objects[1]
end

-- Returns objects of obj_type in a radius --
function Area:queryCircleArea(x, y, radius, object_types)
    local out = {}
    for _, game_object in ipairs(self.game_objects) do
        if fn.any(object_types, game_object.class) then
            local d = distance(x, y, game_object.x, game_object.y)
            if d <= radius then
                table.insert(out, game_object)
            end
        end
    end
    return out
end

-- Takes a filter functio, return a table with objects that return true to the filter func -- 
function Area:getGameObjects(f)
    local out = {}
    for _, game_object in ipairs(self.game_objects) do
        if filter(game_object) then
            table.insert(out, game_object)
        end
        return out
    end
end

function Area:addGameObject(game_object_type, x, y, opts)
    local opts = opts or {}
    local game_object = _G[game_object_type](self, x or 0, y or 0, opts)
    game_object.class = game_object_type
    table.insert(self.game_objects, game_object)
    return game_object
end

function Area:update(dt)
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)
        if game_object.dead then table.remove(self.game_objects, i) end
    end
end

function Area:draw()
    for _, game_objects in ipairs(self.game_objects) do game_objects:draw() end
end
