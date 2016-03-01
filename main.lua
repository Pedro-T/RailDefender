--
-- Author: Pedro Teixeira
-- Date: 2/26/2016
--

-- player "object" for organization - this table holds all info relevant to the player


-- attributes for player-fired bullets
local bulletInfo = {}
bulletInfo["graphic"] = love.graphics.newImage("assets/bullet.png")
bulletInfo["movementSpeed"] = 10

local background = love.graphics.newImage("assets/background.png")

local enemyTemplate = require("data.enemies")
local levelTemplate = require("data.levels")

-- Store bullets and enemies to iterate through for updating/drawing
local aliveBullets = {}
local aliveEnemies = {}

-- Main menu --------------------------------------------------------------------------------------------

local menuStartGame = {}
menuStartGame['text'] = "Start Game"
menuStartGame['action'] = function() gameState = 2 end
local menuExitGame = {}
menuExitGame['text'] = "Exit Game"
menuExitGame['action'] = function() love.event.quit() end
local menu = {}
menu['selectedItem'] = 1
menu['updateCooldown'] = 0.5
menu[1] = menuStartGame
menu[2] = menuExitGame

-- Game-wide variables ---------------------------------------------------------------------------------

local score = 0
local lives = 5

gameState = 1
gameOver = false

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
    player["movementSpeed"] = 150
    player['shotCooldown'] = 0.25
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
        bullet['xpos'] = player.xpos
        bullet['ypos'] = player.ypos
        table.insert(aliveBullets, bullet)
        player.shotCooldown = 0.25
        love.audio.play(shootSound)
    end
end

function checkHit(bulletX, bulletY, unitX, unitY)
    return ((bulletX < unitX + 32) and (bulletX + 32 > unitX) and (bulletY < unitY + 32) and (bulletY + 32 > unitY))
end

function spawnEnemy()
    local enemy = {}
    enemy['graphic'] = love.graphics.newImage("assets/enemyTank.png")
    enemy['xpos'] = math.random(450) + 175
    enemy['ypos'] = math.random(175)
    enemy['movementSpeed'] = 25
    enemy['shotCooldown'] = 1
    enemy['pointValue'] = 25
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

function moveEnemies(delta)
    for i, enemy in ipairs(aliveEnemies) do
        enemy.ypos = enemy.ypos + (enemy.movementSpeed * delta)
        if enemy.ypos > 600 then
            table.remove(aliveEnemies, i)
            loseLife()
        end
    end
end

-- Engine called functions -------------------------------------------------------------------------------

function love.update(delta)
    if gameState == 1 then -- we're in the menu
        updateMenu(delta)
    elseif gameState == 2 then -- we're playing the game
        movePlayer(delta)
        moveEnemies(delta)
        updateBullets()
        if (math.random(100) > 80 and table.getn(aliveEnemies) < 11) then
            spawnEnemy()
        end
    elseif gameState == 3 then -- we've won or lost and are at results screen

    end
    if lives == 0 then
        gameOver = true
    end
end

function love.draw()
    if (gameState == 1) then
        mainMenu()
    else
        if gameOver == false then
            love.graphics.draw(background,0,0)
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
end

function love.load()
    loadAudio()
    createPlayer()
    love.audio.play(stSound)
end