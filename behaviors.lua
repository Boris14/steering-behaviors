local vector = require("libraries.vector")

function SeparationSteer(boid, otherBoids)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    local repulsiveForce = boid.position - v.position
    local distance = repulsiveForce:getmag()
    steering = steering + repulsiveForce:norm() / distance
  end
  
  return steering:setmag(SEPARATION_MULT) 
end

function CohesionSteer(boid, otherBoids)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    steering = steering + v.position
  end
  
  steering = steering / #otherBoids
  steering = steering - boid.position
  
  return steering:setmag(COHESION_MULT)
end

function AlignmentSteer(boid, otherBoids)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    steering = steering + v.forward
  end
  
  steering = steering / #otherBoids
  steering = steering - boid.forward
  
  return steering:setmag(ALIGNMENT_MULT)
end

function FlockingSteer(boid)
  return (SeparationSteer(boid, boid.perceivedBoids) + 
            CohesionSteer(boid, boid.perceivedBoids) + 
            AlignmentSteer(boid, boid.perceivedBoids)) * FORCE_MULTIPLIER
end

function Seek(boid, target)
  local steering = vector(0, 0)
  steering = (target - boid.position):clone():norm() * boid.maxSpeed
  steering = steering - boid.velocity
  return steering
end

function Flee(boid, target)
  local steering = vector(0, 0)
  steering = (boid.position - target):clone():norm() * boid.maxSpeed
  steering = steering - boid.velocity
  return steering
end

function Arrival(boid, target)
  local steering = vector(0, 0)
  local offset = target - boid.position
  local distance = offset:getmag()
  --Used when the target is in slowing distance
  local rampedSpeed = boid.maxSpeed * distance / (boid.perception * 0.6)
  local speed = math.min(rampedSpeed, boid.maxSpeed)
  steering = offset:norm() * speed
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
  local steering = vector(0, 0)
  --local target = leader.position - leader.forward * LEADER_DISTANCE * 2
  --print(leader.forward)
  local leaderAheadPoint = leader.position + leader.velocity
  local target = leader.position + (boid.position - leader.position):setmag(LEADER_DISTANCE * 1.5)
  local distanceFromLeader = (leader.position - boid.position):getmag()
  
  --Get out of the way of the leader
  if (leaderAheadPoint - boid.position):getmag() < LEADER_DISTANCE or distanceFromLeader < LEADER_DISTANCE then
    steering = steering + Flee(boid, leader.position)
  
  --Follow leader
  elseif (target - boid.position):getmag() > ARRIVE_DISTANCE then
    steering = steering + Arrival(boid, target)
    steering = steering + SeparationSteer(boid, otherBoids)
  else
    steering = -boid.velocity
  end

  return steering
end
