--includes
Object = require 'libraries/classic/classic'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Input = require 'libraries/boipushy/Input'
fn = require 'libraries/moses/moses'
Camera = require 'libraries/hump/camera'
Physics = require 'libraries/windfield'
Vector = require 'libraries/hump/vector'
draft = require('libraries/draft/draft')()

require 'libraries/utf8'
require 'utils'
require 'GameObject'
require 'globals'

MODES = 
{
    DEBUG = 0,  -- Memory Dump, files loading, ship aim  --
	DISPLAY_INFO = 1, -- Keep fps counter etc  --
    RELEASE = 2 
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

	--  Load fonts  --
	loadFonts('resources/fonts')
	if MODE == MODES.DEBUG then
		print("Loading fonts: ")
		for k, _ in pairs(fonts) do
			print("    " .. k)
		end
	end
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
	current_room_name = nil
	--gotoRoom('Stage')
	resize(2) --Had to move after camera()
	
	slow_amount = 1
end

-- Room --
function gotoRoom(room_type, ...)
	if current_room and current_room.destroy then current_room:destroy() end
    current_room = _G[room_type](...)
	current_room_name = room_type
end

-- Set input callbacks Boipushy --
function BindInputs()
	input:bind('mouse1', 'test')
	input:bind('left', 'left')
    input:bind('right', 'right')
	input:bind('up', 'up')
	input:bind('down', 'down')

	-- WASD --
	input:bind('a', 'left')
    input:bind('d', 'right')
	input:bind('w', 'up')
	input:bind('s', 'down')
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
	input:bind('f4', function() gotoRoom('Sandbox') end)
	input:bind('f9', function()--  Cycle Modes  --
		if MODE == 2 then
			MODE = 0
		else
			MODE = MODE + 1 
		end
	end)
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

-- Slow down time for duration  --
function slow(amount, duration)
    slow_amount = amount
    timer:tween('slow', duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function love.update(dt)
	timer:update(dt*slow_amount)
    camera:update(dt*slow_amount)
    if current_room then current_room:update(dt*slow_amount) end

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

	if flash_frames then 
        flash_frames = flash_frames - 1
        if flash_frames == -1 then flash_frames = nil end
    end

    if flash_frames then
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', 0, 0, sx*gw, sy*gh)
        love.graphics.setColor(255, 255, 255)
    end

	if MODE < 2 then
		if MODE == 0 then 
			m = 'Debug'
		elseif MODE == 1 then
			m = 'Display'
		end
		love.graphics.print("MODE: "..m, 5, 5 )
		
        fps = math.floor( 1.0 / love.timer.getDelta() )
        love.graphics.print("FPS: "..tostring(fps), 5, 25 )
		if current_room then love.graphics.print("Current Room: "..tostring(current_room_name),5, 45 )
		else love.graphics.print("Current Room: ".. "None",5, 45 ) end
	end
end

-- Frames flashing should last for  --
function flash(frames)
    flash_frames = frames
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

function loadFonts(path)
    fonts = {}
    local font_paths = {}
    recursiveEnumerate(path, font_paths)
    for i = 8, 16, 1 do
        for _, font_path in pairs(font_paths) do
            local last_forward_slash_index = font_path:find("/[^/]*$")
            local font_name = font_path:sub(last_forward_slash_index+1, -5)
            local font = love.graphics.newFont(font_path, i)
            font:setFilter('nearest', 'nearest')
            fonts[font_name .. '_' .. i] = font
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