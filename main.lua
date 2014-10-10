Trophy = require("trophy")

function love.load()
	Trophy:init(100, 0, 15)
	rectangle = {}
	trophy:create_collider(rectangle, 50, 50, 50, 50, .1)
	floor = {}
	trophy:create_collider(floor, 0, 500, 600, 100, 0.5, true)
end

function love.update(dt)
	Trophy:update(dt)
end

function love.keypressed(key, ir)
	
end

function love.draw()
	love.graphics.setColor(54,67,23)
	love.graphics.rectangle("fill", rectangle.col.x, rectangle.col.y, rectangle.col.w, rectangle.col.h)
	love.graphics.rectangle("fill", floor.col.x, floor.col.y, floor.col.w, floor.col.y)
end