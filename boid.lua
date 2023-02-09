local vector = require("libraries.vector")
require("behaviors")

function createBoid()
  --Create the new boid as a table
  local boid = {}
  
  --Add the boids attributes
  boid.position = vector(love.graphics.getWidth() * math.random(), love.graphics.getHeight() * math.random())
  boid.maxSpeed = BOID_MAXSPEED
  boid.maxForce = BOID_MAXFORCE
  boid.size = BOID_SIZE
  boid.perception = BOID_PERCEPTION
  boid.speed = boid.maxSpeed
  boid.velocity = (vector.random()):setmag(boid.speed)
  boid.forward = boid.velocity:clone():norm()
  boid.right = boid.forward:clone():rotate(math.pi/2)
  boid.acceleration = vector(0, 0)
  boid.perceivedBoids = {}
  boid.wanderTarget = vector(0, 0)
  
  --Define the boids methods
  boid.update = function(dt)
    local steering = vector(0, 0) 
    
    --steering = FlockingSteer(boid)
    steering = Wander(boid)
    
    if player then
      steering = FollowLeader(boid, boid.perceivedBoids, player)
    end
    
    --Doesn't work :/
    local sep = SeparationSteer(boid, boid.perceivedBoids, true)
   
   -- print("mag: " .. sep:getmag())
    --print("Steering mag: " .. steering:getmag())
   -- steering = steering + sep * SEPARATION_MULT
    
    steering:limit(boid.maxForce)
 
    boid.applySteering(steering, true)
    
    boid.velocity = boid.velocity + boid.acceleration
    boid.velocity:limit(boid.maxSpeed)
    boid.position = boid.position + boid.velocity * dt
    if(boid.velocity:magSq() > ALMOST_ZERO) then
      boid.forward = boid.velocity:clone():norm()
    end
    boid.right = boid.forward:clone():rotate(math.pi/2)
  end
  
  boid.draw = function()
    --[[  Draw the boid as a triangle (coordinates being its center)
          Firstly, the directions for the vertices vectors are calculated when 
          the boid's angle is 0 (heading right)                                   ]]--
    local triangleHeight = math.sqrt(3)/2 * boid.size
    local leftVector = vector(-triangleHeight/3, -boid.size/2)
    local rightVector = vector(-triangleHeight/3, boid.size/2) 
    local forwardVector = vector(triangleHeight, 0)
    
    --Rotate the vertices vectors 
    local angle = boid.forward:heading()
    rightVector:rotate(angle)
    leftVector:rotate(angle)
    forwardVector:rotate(angle)
    
    local vertices = {boid.position.x + leftVector.x, boid.position.y + leftVector.y, 
                      boid.position.x + forwardVector.x, boid.position.y + forwardVector.y, 
                      boid.position.x + rightVector.x, boid.position.y + rightVector.y}
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("fill", vertices)
    
    --Draw the Perception of the Boid as a circle
    --love.graphics.circle("line", boid.position.x, boid.position.y, boid.perception)
    
    --Draw the Wander circle
    --[[local wanderCircleCenter = boid.position + boid.forward * WANDER_STRENGTH_CIRCLE_DISTANCE
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", (boid.wanderTarget + wanderCircleCenter).x, (boid.wanderTarget + wanderCircleCenter).y, 5)
    love.graphics.setColor(0, 1, 0)
    love.graphics.circle("line", wanderCircleCenter.x, wanderCircleCenter.y, WANDER_STRENGTH_CIRCLE_RADIUS)]]--
  end
  
  boid.applySteering = function(steering, allowBreaking)
    if(allowBreaking or boid.forward:dot(steering) >= 0) then
      boid.acceleration = steering
    else
      local steeringMultiplier = 1
      if boid.right:dot(steering) < 0 then steeringMultiplier = -1 end
      boid.acceleration = boid.right:clone():setmag(steering:getmag()) * steeringMultiplier
    end
  end
  
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
    v.perceivedBoids = getPerceivedBoids(boids, v)
    screenWarp(v.position)
  end
end

function drawBoids(boids)
  for i, v in ipairs(boids) do
    v.draw()
  end
end


function getPerceivedBoids(allBoids, boid)
  local result = {}
  for i, v in ipairs(allBoids) do
    if (v.position - boid.position):getmag() <= boid.perception and v ~= boid then
      table.insert(result, v)
    end
  end
  return result
end

function screenWarp(objectPosition)
  if(objectPosition.x > love.graphics.getWidth()) then
    objectPosition.x = 0
  elseif (objectPosition.x < 0) then
    objectPosition.x = love.graphics.getWidth()
  end
  
  if(objectPosition.y > love.graphics.getHeight()) then
    objectPosition.y = 0
  elseif (objectPosition.y < 0) then
    objectPosition.y = love.graphics.getHeight()
  end
end