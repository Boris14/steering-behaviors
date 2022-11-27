local vector = require("libraries.vector")

function SeparationSteer(boid, otherBoids)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    local repulsiveForce = boid.position - v.position
    local distance = repulsiveForce:getmag()
    steering = steering + repulsiveForce:norm() / distance
  end
  
  return steering:norm()
end

function CohesionSteer(boid, otherBoids)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    steering = steering + v.position
  end
  
  steering = steering / #otherBoids
  steering = steering - boid.position
  
  return steering:norm()
end

function AlignmentSteer(boid, otherBoids)
  local steering = vector(0, 0)
  
  if #otherBoids == 0 then return steering end
  
  for i, v in ipairs(otherBoids) do
    steering = steering + v.forward
  end
  
  steering = steering / #otherBoids
  steering = steering - boid.forward
  
  return steering:norm()
end

