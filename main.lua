require("libraries.vector")
require("boid")
require("player")


--[[

Made the player separate from the other boids (global variable)

This really helps: https://gamedevelopment.tutsplus.com/series/understanding-steering-behaviors--gamedev-12732 

TO DO:
- Make Leader following behaviour. For some reason the separation doesn't work I think.
- Create other behaviour combinations

]]--


player = createPlayer()
local boids = {}

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.load()
  love.window.setFullscreen(true)
  font = love.graphics.newFont(20)
  boids = createBoids(BOIDS_COUNT)
end

function love.update(dt)
  updateBoids(boids, dt)
  player.update(dt)
end

function love.draw()
  drawBoids(boids)
  player.draw()
end