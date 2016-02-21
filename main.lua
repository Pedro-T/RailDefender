--
-- Created by IntelliJ IDEA.
-- User: Pedro
-- Date: 2/21/2016
-- Time: Version: 0.1
--

-- player "object" for organization - this table holds all info relevant to the player
player = {}
player["graphic"] = love.graphics.newImage("\\assets\\player.png")
player["xpos"] = 0
player["ypos"] = 500
player["movementSpeed"] = 100
player['shotCooldown'] = 0

-- attributes for player-fired bullets
bulletInfo = {}
bulletInfo["graphic"] = love.graphics.newImage("bullet.png")
bulletInfo["movementSpeed"] = 5

-- Store bullets and enemies to iterate through for updating/drawing
aliveBullets = {}
aliveEnemies = {}

-- Check if the player is allowed to fire a shot, then spawn a bullet at their position and give a cooldown time
function fireBullet()
    if (player.shotCooldown == 0) then
        bullet = {}
        bullet['xpos'] = player.xpos
        bullet['ypos'] = player.ypos
        table.insert(aliveBullets, bullet)
        player.shotCooldown = 0.25
    end
end

function spawnEnemy()
    enemy = {}
    enemy['xpos'] = 0
    enemy['xpos'] = 0
    enemy['graphic'] = 0
    table.insert(aliveEnemies, enemy)
end

function updateBullets()
    for i, bullet in ipairs(aliveBullets) do
        aliveBullets[i].ypos = aliveBullets[i].ypos - bulletInfo.movementSpeed
        if (bullet.ypos < -10) then
            table.remove(aliveBullets, i)
        end
    end
end

-- This does too many things

function movePlayer(delta)
    if love.keyboard.isDown('s','right') then
        if player.xpos < (800 - player.movementSpeed * delta) then
            player.xpos = player.xpos + (player.movementSpeed * delta)
        end
    elseif love.keyboard.isDown('a','left') then
        if player.xpos > player.movementSpeed * delta then
            player.xpos = player.xpos - (player.movementSpeed * delta)
        end
    end
    if love.keyboard.isDown('space') then
        fireBullet()
    end
    player.shotCooldown = player.shotCooldown - delta
    if (player.shotCooldown < 0) then
        player.shotCooldown = 0
    end
end

-- Engine called functions

function love.update(delta)
    movePlayer(delta)
    updateBullets()
end

function love.draw()
    love.graphics.draw(player.graphic, player.xpos, player.ypos)
    for i, bullet in ipairs(aliveBullets) do
        love.graphics.draw(bulletInfo.graphic, bullet.xpos, bullet.ypos)
    end
    for i, enemy in ipairs(aliveEnemies) do
        love.graphics.draw(enemy.graphic, enemy.xpos, enemy.xpos)
    end
end

function love.load()

end