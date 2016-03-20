--
-- Author: Pedro Teixeira
-- Date: 3/20/2016
--

-- attributes for player-fired bullets
local bulletInfo = {}
bulletInfo["graphic"] = love.graphics.newImage("assets/playerBullet.png")
bulletInfo["movementSpeed"] = 300

local tankShotGraphic = love.graphics.newImage("assets/tankShot.png")

local gameState = 1
gameOver = false
local currentLevel = 2
intermissionTimer = 0
gameOverConditionWin = true

local background = love.graphics.newImage("assets/background.png")

local enemyTemplate = require("data.enemies")
local levelTemplate = require("data.levels")

-- Store bullets and enemies to iterate through for updating/drawing
local aliveBullets = {}
local aliveEnemies = {}
local aliveEnemyBullets = {}
local effects = {}

-- Main menu --------------------------------------------------------------------------------------------

local menuStartGame = {}
menuStartGame['text'] = "Start Game"
menuStartGame['action'] = function() gameState = 2 end
local menuCredits  = {}
menuCredits['text'] = "Credits"
menuCredits['action'] = function()
    love.audio.pause()
    gameState = 6
end
local menuExitGame = {}
menuExitGame['text'] = "Exit Game"
menuExitGame['action'] = function() love.event.quit() end
local menu = {}
menu['selectedItem'] = 1
menu['updateCooldown'] = 0.5
menu[1] = menuStartGame
menu[2] = menuCredits
menu[3] = menuExitGame

-- Game-wide variables ---------------------------------------------------------------------------------

local score = 0
local lives = 5
local deadEnemies = 0


local spawnerCooldown = 0

-- Menu activities


function updateMenu(delta)
    if menu.updateCooldown > 0 then
        menu.updateCooldown = menu.updateCooldown - delta
    else
       if love.keyboard.isDown('up', 'w') and menu.selectedItem > 1 then
           menu.selectedItem = menu.selectedItem - 1
       elseif love.keyboard.isDown('down', 's') and menu.selectedItem < 2 then
           menu.selectedItem = menu.selectedItem + 1
       elseif love.keyboard.isDown('return') then
           menu[menu.selectedItem].action()
       end
   end
end

function advanceLevel()
    if currentLevel == 4 then
        gameState = 3
    else
        clearEnemies()
        currentLevel = currentLevel + 1
        intermissionTimer = 5
        gameState = 3
        deadEnemies = 0
    end
end

-- Load our assets and set up some structures

function mainMenu()
    for i, menuItem in ipairs(menu) do
        love.graphics.print(menuItem.text, 300, (200 + i * 25))
        if (menu.selectedItem == i) then love.graphics.print(">", 290, (200 + i * 25)) end
    end
end

function createPlayer()
    local player = {}
    player["graphic"] = love.graphics.newImage("assets/player.png")
    player["xpos"] = 150
    player["ypos"] = 420
    player['xSize'] = 32
    player['ySize'] = 32
    player["movementSpeed"] = 150
    player['shotCooldown'] = 0.25
    return player
end

function loadAudio()
    shootSound = love.audio.newSource("assets/shoot.wav")
    stSound = love.audio.newSource("assets/soundTrack.mp3")
    stSound:setVolume(0.15)
    stSound:setLooping(true)
end


-- Shooting activities ------------------------------------------------------------------------------
function fireBullet()
    if (player.shotCooldown == 0) then
        local bullet = {}
        bullet['xpos'] = player.xpos + (player.graphic:getWidth()/2 - bulletInfo.graphic:getWidth() / 2)
        bullet['ypos'] = player.ypos
        table.insert(aliveBullets, bullet)
        player.shotCooldown = 0.25
        love.audio.play(shootSound)
    end
end

function fireEnemyBullet(enemy, delta)
    if enemy.shotCooldown <= 0 then
        local bullet = {}
        bullet['xpos'] = enemy.xpos
        bullet['ypos'] = enemy.ypos
        bullet['graphic'] = tankShotGraphic
        if enemy.hasAccurateFire then
            local angle = math.atan((player.ypos + player.width / 2) - (enemy.ypos + enemy.width / 2), (player.xpos + player.width / 2) - (enemy.xpos + enemy.width / 2))
            bullet['dx'] = enemy.bulletSpeed * math.cos(angle)
            bullet['dy'] = enemy.bulletSpeed * math.sin(angle)
        else
            bullet['dx'] = 0
            bullet['dy'] = enemy.bulletSpeed
        end
        table.insert(aliveEnemyBullets, bullet)
        enemy.shotCooldown = enemy.shotInterval
    else
        enemy.shotCooldown = enemy.shotCooldown - delta
    end
end

function checkHit(bullet, unit)
    return ((bullet.xpos < unit.xpos + unit.xSize) and (bullet.xpos + bulletInfo.graphic:getWidth() > unit.xpos) and (bullet.ypos < unit.ypos + unit.ySize) and (bullet.ypos + bulletInfo.graphic:getWidth() > unit.ypos))
end

function spawnEnemy()
    local enemyIndex = math.random(levelTemplate[currentLevel].enemyBoundA, levelTemplate[currentLevel].enemyBoundB)
    local enemy = {}
    enemy['animation'] = enemyTemplate[enemyIndex].moveAnimation:clone()
    enemy['spriteSheet'] = enemyTemplate[enemyIndex].spriteSheet
    enemy['xpos'] = math.random(450) + 175
    enemy.deathAnimation = enemyTemplate[enemyIndex].deathAnimation
    enemy['ypos'] = -30
    enemy['xSize'] = enemyTemplate[enemyIndex].xSize
    enemy['bulletSpeed'] = enemyTemplate[enemyIndex].bulletSpeed
    enemy['ySize'] = enemyTemplate[enemyIndex].ySize
    enemy['movementSpeed'] = enemyTemplate[enemyIndex].movementSpeed
    enemy['shootsAtPlayer'] = enemyTemplate[enemyIndex].shootsAtPlayer
    if enemy.shootsAtPlayer then
        enemy['shotInterval'] = enemyTemplate[enemyIndex].shotInterval
        enemy['shotCooldown'] = 3
    end
    enemy['pointValue'] = 25
    enemy['hitpoints'] = enemyTemplate[enemyIndex].hitpoints
    table.insert(aliveEnemies, enemy)
end

function loseLife()
    score = score - 250
    lives = lives - 1
end



-- Move things around -----------------------------------------------------------------------------

function movePlayer(delta)
    if love.keyboard.isDown('d','right') then
        if player.xpos < (650 - player.movementSpeed * delta) then
            player.xpos = player.xpos + (player.movementSpeed * delta)
        end
    elseif love.keyboard.isDown('a','left') then
        if player.xpos > (150 + player.movementSpeed * delta) then
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

function updateBullets(delta)
    for i, bullet in ipairs(aliveBullets) do
        aliveBullets[i].ypos = aliveBullets[i].ypos - (bulletInfo.movementSpeed * delta)
        if (bullet.ypos < -10) then
            table.remove(aliveBullets, i)
        end
        for j, enemy in ipairs(aliveEnemies) do
            if checkHit(bullet, enemy) then
                enemy.hitpoints = enemy.hitpoints - 1
                if enemy.hitpoints <= 0 then
                    table.remove(aliveEnemies, j)
                    deadEnemies = deadEnemies + 1
                    score = score + enemy.pointValue
                    local effect = {}
                    effect.animation = enemy.deathAnimation:clone()
                    effect.spriteSheet = enemy.spriteSheet
                    effect.xpos = enemy.xpos
                    effect.ypos = enemy.ypos
                    table.insert(effects, effect)
                end
                table.remove(aliveBullets, i)
            end
        end
    end
    for k, bullet in ipairs(aliveEnemyBullets) do
        bullet.xpos = bullet.xpos + (bullet.dx * delta)
        bullet.ypos = bullet.ypos + (bullet.dy * delta)
        if (bullet.ypos < -10) then
            table.remove(aliveEnemyBullets, k)
        end
        if (checkHit(bullet, player)) then
            loseLife()
            table.remove(aliveEnemyBullets, k)
        end
    end
end

function moveEnemies(delta)
    for i, enemy in ipairs(aliveEnemies) do
        enemy.ypos = enemy.ypos + (enemy.movementSpeed * delta)
        enemy.animation:update(delta)
        if enemy.ypos > 600 then
            table.remove(aliveEnemies, i)
            loseLife()
        elseif enemy.shootsAtPlayer then fireEnemyBullet(enemy, delta)

        end
    end
end

function clearEnemies()
    local count = #aliveEnemies
    for i=0, count do
        aliveEnemies[i] = nil
    end
end

-- Engine called functions -------------------------------------------------------------------------------

function love.update(delta)
    if gameState == 1 then -- we're in the menu
        updateMenu(delta)
    elseif gameState == 2 then -- we're playing the game
        if (deadEnemies >= levelTemplate[currentLevel].enemyCount) then
            advanceLevel()
        end
        movePlayer(delta)
        moveEnemies(delta)
        updateBullets(delta)
        if spawnerCooldown <= 0 then
            spawnEnemy()
            spawnerCooldown = levelTemplate[currentLevel].enemySpawnIntervalMax
        end
        for i, effect in ipairs(effects) do
            effect.animation:update(delta)
        end
    spawnerCooldown = spawnerCooldown - delta
    elseif gameState == 3 then -- level intermission
        intermissionTimer = intermissionTimer - delta
        if intermissionTimer <= 0 then
            gameState = 2
        end
    end
    if lives == 0 then
        gameState = 5
    end

end

function love.draw()
    if (gameState == 1) then
        mainMenu()
    elseif gameState == 2 then
        if gameOver == false then
            love.graphics.draw(background,0,0)
            love.graphics.draw(player.graphic, player.xpos, player.ypos)
            for i, bullet in ipairs(aliveBullets) do
                love.graphics.draw(bulletInfo.graphic, bullet.xpos, bullet.ypos)
            end
            for j, enemy in ipairs(aliveEnemies) do
                enemy.animation:draw(enemy.spriteSheet, enemy.xpos, enemy.ypos)
            end
            for k, effect in ipairs(effects) do
                effect.animation:draw(effect.spriteSheet, effect.xpos, effect.ypos)
            end
            for l, bullet in ipairs(aliveEnemyBullets) do
                love.graphics.draw(bullet.graphic, bullet.xpos, bullet.ypos)
            end
            love.graphics.print("Score: " .. score, 400, 50)
            love.graphics.print("Level: " .. currentLevel, 400, 65)
        end
    elseif gameState == 3 then
        love.graphics.print("Level Complete!", 400, 300)
        love.graphics.print("Score: " .. score, 400, 320)
        love.graphics.print("Next level in..." .. intermissionTimer)
    elseif gameState == 4 then
        love.graphics.print("Victory!", 350, 200)
        love.graphics.print("Your score: " .. score, 350, 250)
    elseif gameState == 5 then
        love.graphics.print("Game over! You lose!", 350, 200)
        love.graphics.print("Your score: " .. score, 350, 250)
    elseif gameState == 6 then
        love.graphics.print("Credits", 50, 100)
        love.graphics.print("Code: Pedro Teixeira\nArt: Pedro Teixeira\nMusic: Jay Man (Check out more at ourmusicbox.com)\nLove2D Framework: Rude (love2d.org)\nAnim8 library: Kikito (github.com/kikito/anim8)", 50, 150)
    end
end

function love.load()
    player = createPlayer()
    loadAudio()
    love.window.setTitle("RailDefender")
    love.audio.play(stSound)
end