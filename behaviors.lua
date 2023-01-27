local vector = require("libraries.vector")

function SeparationSteer(boid, otherBoids, normalized)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    local repulsiveForce = boid.position - v.position
    local distance = repulsiveForce:getmag()
    steering = steering + repulsiveForce:norm() / distance
  end
  
  if normalized then return steering:norm() end
  return steering
end

function CohesionSteer(boid, otherBoids, normalized)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    steering = steering + v.position
  end
  
  steering = steering / #otherBoids
  steering = steering - boid.position
  
  if normalized then return steering:norm() end
  return steering
end

function AlignmentSteer(boid, otherBoids, normalized)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    steering = steering + v.forward
  end
  
  steering = steering / #otherBoids
  steering = steering - boid.forward
  
  if normalized then return steering:norm() end
  return steering
end

function FlockingSteer(boid)
  return (SEPARATION_MULT * SeparationSteer(boid, boid.perceivedBoids, true) + 
            COHESION_MULT * CohesionSteer(boid, boid.perceivedBoids, true) + 
            ALIGNMENT_MULT * AlignmentSteer(boid, boid.perceivedBoids, true)) * FORCE_MULTIPLIER
end

function Seek(boid, target)
  local steering = vector(0, 0)
  steering = (target - boid.position):clone():norm() * boid.speed
  steering = steering - boid.velocity
  return steering
end

function Flee(boid, target)
  local steering = vector(0, 0)
  steering = (boid.position - target):clone():norm() * boid.speed
  steering = steering - boid.velocity
  return steering
end

function Arrival(boid, target)
  local steering = vector(0, 0)
  local offset = target - boid.position
  local distance = offset:getmag()
  steering = offset:norm() * boid.maxSpeed * distance / (boid.perception * 0.6)
  steering = steering - boid.velocity
  return steering
end

function Wander(boid)
  local steering = vector(0, 0)
  local wanderCircleCenter = boid.position + boid.forward * WANDER_STRENGTH_CIRCLE_DISTANCE
  if(boid.wanderTarget == vector(0, 0)) then
    boid.wanderTarget = vector.random():setmag(WANDER_STRENGTH_CIRCLE_RADIUS)
  else
    boid.wanderTarget:rotate(math.random(-1, 1) * WANDER_RATE_CIRCLE_RADIUS):setmag(WANDER_STRENGTH_CIRCLE_RADIUS)
  end
  return Seek(boid, boid.wanderTarget + wanderCircleCenter)
end

function FollowLeader(boid, otherBoids, leader)
  
end
