local vector = require("libraries.vector")
require("boid")

function createPlayer()
  local player = createBoid()
  
  player.size = PLAYER_SIZE
  player.isPlayer = true
  
  --Override the update and draw functions
  player.update = function(dt)
    local newVelocity = vector(0, 0)
    if love.keyboard.isDown("w") then
      newVelocity.y = newVelocity.y - player.maxSpeed
    end
    if love.keyboard.isDown("a") then
      newVelocity.x = newVelocity.x - player.maxSpeed
    end
    if love.keyboard.isDown("s") then
      newVelocity.y = newVelocity.y + player.maxSpeed
    end
    if love.keyboard.isDown("d") then
      newVelocity.x = newVelocity.x + player.maxSpeed
    end
    
    player.velocity = newVelocity
    player.position = player.position + player.velocity * dt
    player.forward = player.velocity:clone():norm()
    player.right = player.forward:clone():rotate(math.pi/2)
    player.orientation = player.velocity:heading()
  end
  
  player.draw = function()
    love.graphics.circle("fill", player.position.x, player.position.y, player.size)
  end
  
    
  return player
end