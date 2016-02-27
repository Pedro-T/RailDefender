--
-- Created by IntelliJ IDEA.
-- User: Pedro
-- Date: 2/26/2016
--

-- player "object" for organization - this table holds all info relevant to the player
player = {}
player["graphic"] = love.graphics.newImage("player.png")
player["xpos"] = 300
player["ypos"] = 500
player["movementSpeed"] = 100
player['shotCooldown'] = 0.25

-- attributes for player-fired bullets
bulletInfo = {}
bulletInfo["graphic"] = love.graphics.newImage("bullet.png")
bulletInfo["movementSpeed"] = 10

-- Store bullets and enemies to iterate through for updating/drawing
aliveBullets = {}
aliveEnemies = {}

score = 0
lives = 5

gameOver = false


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

function checkHit(bulletX, bulletY, unitX, unitY)
    return ((bulletX < unitX + 32) and (bulletX + 32 > unitX) and (bulletY < unitY + 32) and (bulletY + 32 > unitY))
end

function spawnEnemy()
    enemy = {}
    enemy['graphic'] = love.graphics.newImage("enemyTank.png")
    enemy['xpos'] = math.random(700)
    enemy['ypos'] = math.random(300)
    enemy['movementSpeed'] = 25
    enemy['shotCooldown'] = 1
    enemy['pointValue'] = 25
    table.insert(aliveEnemies, enemy)
end

function updateBullets()
    for i, bullet in ipairs(aliveBullets) do
        aliveBullets[i].ypos = aliveBullets[i].ypos - bulletInfo.movementSpeed
        if (bullet.ypos < -10) then
            table.remove(aliveBullets, i)
        end
        for j, enemy in ipairs(aliveEnemies) do
            if checkHit(bullet.xpos, bullet.ypos, enemy.xpos, enemy.ypos) then
                table.remove(aliveEnemies, j)
                score = score + enemy.pointValue
            end
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

function loseLife()
    score = score - 250
    lives = lives - 1
end

function moveEnemies(delta)
    for i, enemy in ipairs(aliveEnemies) do
        enemy.ypos = enemy.ypos + (enemy.movementSpeed * delta)
        if enemy.ypos > 600 then
            table.remove(aliveEnemies, i)
            loseLife()
        end
    end
end

-- Engine called functions

function love.update(delta)
    if gameOver == false then
        movePlayer(delta)
        moveEnemies(delta)
        updateBullets()
        if (math.random(100) > 80 and table.getn(aliveEnemies) < 11) then
            spawnEnemy()
        end
    end
    if lives == 0 then
        gameOver = true
    end
end

function love.draw()
    if gameOver == false then
        love.graphics.draw(player.graphic, player.xpos, player.ypos)
        for i, bullet in ipairs(aliveBullets) do
            love.graphics.draw(bulletInfo.graphic, bullet.xpos, bullet.ypos)
        end
        for j, enemy in ipairs(aliveEnemies) do
            love.graphics.draw(enemy.graphic, enemy.xpos, enemy.ypos)
        end
        love.graphics.print("Score: " .. score, 400, 50)
    else
        love.graphics.print("Game over!", 350, 200)
        love.graphics.print("Your score: " .. score, 350, 250)
    end

end

function love.load()

end