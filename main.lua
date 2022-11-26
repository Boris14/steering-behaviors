require("libraries.vector")
require("boid")

local boids = {}

function love.load()
  boids = createBoids(BOIDS_COUNT)
end

function love.update(dt)
  updateBoids(boids, dt)
end

function love.draw()
  drawBoids(boids)
end