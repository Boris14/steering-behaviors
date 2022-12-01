require("libraries.vector")
require("boid")
require("player")

local boids = {}
--local player = {}

function love.load()
  font = love.graphics.newFont(20)
  boids = createBoids(BOIDS_COUNT)
  --table.insert(boids, createPlayer())
end

function love.update(dt)
  updateBoids(boids, dt)
  --player.update(dt)
end

function love.draw()
  drawBoids(boids)
  --player.draw()
end