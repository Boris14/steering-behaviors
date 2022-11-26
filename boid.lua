--https://github.com/mcnorwalk/vector.lua
local vector = require("libraries.vector")

function createBoid()
  --Create the new boid as a table
  local boid = {}
  
  --Define the boids methods
  boid.update = function(dt)
    boid.velocity = boid.velocity + boid.acceleration
    boid.forward = boid.velocity:norm()
    boid.angle = boid.velocity:heading()
    
    boid.x = boid.x + boid.velocity.x * dt * 100
    boid.y = boid.y + boid.velocity.y * dt * 100
  end
  
  boid.draw = function ()
    --[[  Draw the boid as a triangle (coordinates being its center)
          Firstly, the directions for the vertices vectors are calculated when 
          the boid's angle is 0 (heading right)                                   ]]--
    local triangleHeight = math.sqrt(3)/2 * boid.size
    local leftVector = vector(-triangleHeight/3, -boid.size/2)
    local rightVector = vector(-triangleHeight/3, boid.size/2) 
    local forwardVector = vector(triangleHeight, 0)
    
    --Rotate the vertices vectors 
    rightVector:rotate(boid.angle)
    leftVector:rotate(boid.angle)
    forwardVector:rotate(boid.angle)
    
    local vertices = {boid.x + leftVector.x, boid.y + leftVector.y, 
                      boid.x + forwardVector.x, boid.y + forwardVector.y, 
                      boid.x + rightVector.x, boid.y + rightVector.y}
    
    love.graphics.polygon("fill", vertices)
  end
  
  
  --Set the boids attributes
  boid.x = love.graphics.getWidth() / 2
  boid.y = love.graphics.getHeight() / 2
  boid.maxSpeed = BOID_MAXSPEED
  boid.size = BOID_SIZE
  boid.speed = 90
  boid.velocity = vector.random():norm() * boid.speed
  boid.forward = boid.velocity:norm()
  boid.angle = boid.velocity:heading() --in Radians (0 means heading right ->)
  boid.acceleration = vector(0, 0)
  
  return boid
end

function createBoids(count)
  local newBoids = {}
  for i = 0, count do
    newBoids[i] = createBoid()
  end
  return newBoids
end

function updateBoids(boids, dt)
  for i, v in ipairs(boids) do
    v.update(dt)
  end
end

function drawBoids(boids)
  for i, v in ipairs(boids) do
    v.draw()
  end
end