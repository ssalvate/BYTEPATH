--includes
Object = require 'libraries/classic/classic'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Input = require 'libraries/boipushy/Input'
fn = require 'libraries/moses/moses'
Camera = require 'libraries/hump/camera'
Physics = require 'libraries/windfield'

require 'utils'
require 'GameObject'

MODES = 
{
    DEBUG = 0,
    RELEASE = 1 
}

MODE = 0

-- Resize the game window --
function resize(s)
    love.window.setMode(s*gw, s*gh, {vsync = 1}) 
    sx, sy = s, s
end

function love.load()
	--set window properties
	
	love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')

	--load object folder files
	local object_files = {}
    recursiveEnumerate('objects', object_files)
	if MODE == MODES.DEBUG then
		print("Loading Obj Files: ")
		for _, file in pairs(object_files) do
			print("    " .. file)
		end
	end
	requireFiles(object_files)

	--load room folder files
	local room_files = {}
    recursiveEnumerate('rooms', room_files)
	if MODE == MODES.DEBUG then
		print("Loading Room Files: ")
		for _, file in pairs(room_files) do
			print("    " .. file)
		end
	end
	requireFiles(room_files)

	--Init Debug vars
	frame = 0

	timer = Timer()
	input = Input()
	camera = Camera()
	BindInputs()
	
	current_room = nil
	--gotoRoom('Stage')
	resize(2) --Had to move after camera()
end

-- Room --
function gotoRoom(room_type, ...)
	if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
end

-- Set input callbacks Boipushy --
function BindInputs()
	input:bind('mouse1', 'test')
	input:bind('left', 'left')
    input:bind('right', 'right')

	-- WASD --
	input:bind('a', 'left')
    input:bind('d', 'right')
	-- F# keys --
	input:bind('f1', function()-- Memory Info  --
		print()
		print("----------Memory Info-----------------")
        print("Before collection: " .. collectgarbage("count")/1024)
        collectgarbage()
        print("After collection: " .. collectgarbage("count")/1024)
        print("Object count: ")
        local counts = type_count()
        for k, v in pairs(counts) do print(k, v) end
        print("-------------------------------------")
    end)
	input:bind('f2', function() gotoRoom('Stage') end)
	input:bind('f3', function() 
        if current_room then
            current_room:destroy()
            current_room = nil
        end
    end)
	input:bind('f4', function() camera:shake(4, 60, 1) end)
	-- Gamepad Controller --
	input:bind('dpleft', 'left')
	input:bind('dpright', 'right')
	input:bind('dpup', 'up')
	input:bind('dpdown', 'down')
	input:bind('l2', 'trigger')
	input:bind('leftx', 'left_horizontal')
	input:bind('lefty', 'left_vertical')
	input:bind('rightx', 'right_horizontal')
	input:bind('righty', 'right_vertical')
end

function love.keypressed(key)
end

function love.update(dt)
	timer:update(dt)
	camera:update(dt)
	if current_room then current_room:update(dt) end

	frame = frame + 1
	if MODE == MODES.DEBUG then
		if input:pressed('test') then print('pressed') end
		if input:released('test') then print('released') end
		if input:down('test', 0.5) then print('test event') end
		--Gamepad
		--[[if input:pressed('left') then print('left') end
		if input:pressed('right') then print('right') end
		if input:pressed('up') then print('up') end
		if input:pressed('down') then print('down') end
		local left_trigger_value = input:down('trigger')
		print(left_trigger_value)
		local left_stick_horizontal = input:down('left_horizontal')
		local left_stick_vertical = input:down('left_vertical')
		local right_stick_horizontal = input:down('right_horizontal')
		local right_stick_vertical = input:down('right_vertical')
		print(left_stick_horizontal, left_stick_vertical)
		print(right_stick_horizontal, right_stick_vertical)]]
	end
end

function love.draw()
	if current_room then current_room:draw() end
	
	if MODE == MODES.DEBUG then
        fps = math.floor( 1.0 / love.timer.getDelta() )
        love.graphics.print("FPS: "..tostring(fps , 10, 10) ) 
    end
end

-- Memory Usage/Info Start--
function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
	    seen[t] = true
	    for k,v in pairs(t) do
	        if type(v) == "table" then
		    count_table(v)
	        elseif type(v) == "userdata" then
		    f(v)
	        end
	end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
	global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end
-- Memory Usage/Info End--

-- Load --
function recursiveEnumerate(folder, file_list)
	local items = love.filesystem.getDirectoryItems(folder)
	for _, item in ipairs(items) do
		local file = folder .. '/' .. item
		if love.filesystem.isFile(file) then
			table.insert(file_list, file)
		elseif love.filesystem.isDirectory(file) then
			recursiveEnumerate(file, file_list)
		end
	end
end

function requireFiles(files)
	for _, file in ipairs(files) do
		local file = file:sub(1, -5)
		require(file)
	end
end

function love.run()--Sem Fixed
	if love.math then love.math.setRandomSeed(os.time()) end
	if love.load then love.load(arg) end
	if love.timer then love.timer.step() end
 
	local dt = 0
	local fixed_dt = 1/60
	local accumulator = 0
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
 
		-- Call update and draw
		accumulator = accumulator + dt
		--print("Accumulator: "..tostring(accumulator) ) 
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end
 
		if love.timer then love.timer.sleep(0.001) end
	end
end