--includes
Object = require 'libraries/classic/classic'
Timer = require 'libraries/enhanced_timer/EnhancedTimer'
Input = require 'libraries/boipushy/Input'
fn = require 'libraries/moses/moses'

local MODES = 
{
    DEBUG = 0,
    RELEASE = 1 
}

local MODE = 0

function love.load()

	a = {1, 2, '3', 4, '5', 6, 7, true, 9, 10, 11, a = 1, b = 2, c = 3, {1, 2, 3}}
	b = {1, 1, 3, 4, 5, 6, 7, false}
	c = {'1', '2', '3', 4, 5, 6, 7}
	d = {1, 9, 3, 4, 5, 6}	
	
	local e = fn.intersection(b, d)
	fn.each(e, print)

	counter_table = createCounterTable()
    counter_table:sum()
	print(counter_table.value)
	
	--load object folder files
	local object_files = {}
    recursiveEnumerate('objects', object_files)
	
	if MODE == MODES.DEBUG then
		print("Loading Files: ")
		for _, file in pairs(object_files) do
			print("    " .. file)
		end
	end
	
	requireFiles(object_files)

	--set window properties
    love.window.setMode(800, 600, {vsync = 1})
	--Init Debug vars
	frame = 0
	
	--test_instance = Test()
	--circle_instance = HyperCircle(400,300,50, 10,120)

	timer = Timer()
	circle = {radius = 24}
	gw = 600
	gh = 800
	hp_bar_bg = {x = gw/2, y = gh/2, w = 200, h = 40}
    hp_bar_fg = {x = gw/2, y = gh/2, w = 200, h = 40}

	BindInput()
	
end

function BindInput()
	input = Input()
    input:bind('mouse1', 'test')
	--Gamepad
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

function createCounterTable()
    return {
		a=1,
		b=2,
		c=3,
        value = 0,
        sum = function(self) self.value = self.a + self.b + self.c end,
    }
end

function love.keypressed(key)
	function love.keypressed(key)
		if key == 'e' then
			timer:cancel('shrink')
			timer:tween('expand', 6, circle, {radius = 96}, 'in-out-cubic')
		elseif key == 's' then
			timer:cancel('expand')
			timer:tween('shrink', 6, circle, {radius = 24}, 'in-out-cubic')
		end
	end
	if key == 'd' then
		timer:tween('fg', 0.5, hp_bar_fg, {w = hp_bar_fg.w - 25}, 'in-out-cubic')
		timer:after('bg_after', 0.25, function()
            timer:tween('bg_tween', 0.5, hp_bar_bg, {w = hp_bar_bg.w - 25}, 'in-out-cubic')
        end)
	end

    if key == 'r' then
        timer:after('r_key_press', 2, function() print(love.math.random()) end)
    end
end

function love.update(dt)
	timer:update(dt)
	--circle_instance:update()
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
	--circle_instance:draw()
	love.graphics.circle('fill', 400, 300, circle.radius)
	--[[love.graphics.setColor(222, 64, 64)
    love.graphics.rectangle('fill', hp_bar_bg.x, hp_bar_bg.y - hp_bar_bg.h/2, hp_bar_bg.w, hp_bar_bg.h)
    love.graphics.setColor(222, 96, 96)
    love.graphics.rectangle('fill', hp_bar_fg.x, hp_bar_fg.y - hp_bar_fg.h/2, hp_bar_fg.w, hp_bar_fg.h)
    love.graphics.setColor(255, 255, 255)]]
	
	if MODE == MODES.DEBUG then
        fps = math.floor( 1.0 / love.timer.getDelta() )
        love.graphics.print("FPS: "..tostring(fps , 10, 10) ) 
    end
end

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
		local name = file:match("^.+/(.+)$")
		require(file)
		--_G[name] = require(file) --Add objects created to Lua global table
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