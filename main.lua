--
-- Author: Pedro Teixeira
-- Date: 4/8/2016
--

local bullets = require("bullets")
local enemyTemplate = require("data.enemies")
local levelTemplate = require("data.levels")

local player = {}
player["graphic"] = love.graphics.newImage("assets/player.png")
player["xpos"] = 150
player["ypos"] = 420
player['xSize'] = 32
player['ySize'] = 32
player["movementSpeed"] = 150
player['shotCooldown'] = 0.25
player.lives = 5
player.loseLife = function() player.lives = player.lives - 1 end

local game = {}
game['score'] = 0
game['deadEnemies'] = 0
game['spawnerCooldown'] = 0
game['gameState'] = 1
game['currentLevel'] = 1
game['intermissionTimer'] = 0
game['gameOver'] = false
game.effects = {}

local background = love.graphics.newImage("assets/background.png")

-- Store enemies to iterate through for updating/drawing
game.aliveEnemies = {}

-- Main menu --------------------------------------------------------------------------------------------

local menuStartGame = {}
menuStartGame['text'] = "Start Game"
menuStartGame['action'] = function()
    game.gameState = 2
end
local menuCredits  = {}
menuCredits['text'] = "Credits"
menuCredits['action'] = function()
    love.audio.pause()
    game.gameState = 6
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

-- Menu activities


local function updateMenu(delta)
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

local function clearEnemies()
    local count = #game.aliveEnemies
    for i=0, count do
        game.aliveEnemies[i] = nil
    end
end

local function advanceLevel()
    if (game.currentLevel == 4) then
        game.gameState = 4
    else
        clearEnemies()
        game.gameState = 3
        game.intermissionTimer = 5
        game.currentLevel = game.currentLevel + 1
    end

end

-- Load our assets and set up some structures

local function mainMenu()
    for i, menuItem in ipairs(menu) do
        love.graphics.print(menuItem.text, 300, (200 + i * 25))
        if (menu.selectedItem == i) then love.graphics.print(">", 290, (200 + i * 25)) end
    end
end

local function spawnEnemy()
    local enemyIndex = math.random(levelTemplate[game.currentLevel].enemyBoundA, levelTemplate[game.currentLevel].enemyBoundB)
    local enemy = {}
    for key, value in pairs(enemyTemplate[enemyIndex]) do
        enemy[key] = value
    end
    enemy['xpos'] = math.random(450) + 175
    enemy['ypos'] = -30
    table.insert(game.aliveEnemies, enemy)
end

-- Move things around -----------------------------------------------------------------------------

local function movePlayer(delta)
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
        bullets.fireBullet(player)
    end
    player.shotCooldown = player.shotCooldown - delta
    if (player.shotCooldown < 0) then
        player.shotCooldown = 0
    end
end

local function moveEnemies(delta)
    for i, enemy in ipairs(game.aliveEnemies) do
        enemy.ypos = enemy.ypos + (enemy.movementSpeed * delta)
        enemy.moveAnimation:update(delta)
        if enemy.ypos > 600 then
            table.remove(game.aliveEnemies, i)
            player.loseLife()
        elseif enemy.shootsAtPlayer then bullets.fireEnemyBullet(player, enemy, delta)

        end
    end
end



-- Engine called functions -------------------------------------------------------------------------------

function love.update(delta)
    if game.gameState == 1 then -- we're in the menu
        updateMenu(delta)
    elseif game.gameState == 2 then -- we're playing the game
        if (game.deadEnemies >= levelTemplate[game.currentLevel].enemyCount) then
            advanceLevel()
        end
        movePlayer(delta)
        moveEnemies(delta)
        bullets.updateBullets(player, delta, game)
        if game.spawnerCooldown <= 0 then
            spawnEnemy()
            game.spawnerCooldown = levelTemplate[game.currentLevel].enemySpawnIntervalMax
        end
        for i, effect in ipairs(game.effects) do
            effect.animation:update(delta)
        end
    game.spawnerCooldown = game.spawnerCooldown - delta
    elseif game.gameState == 3 then -- level intermission
        game.intermissionTimer = game.intermissionTimer - delta
        if game.intermissionTimer <= 0 then
            game.gameState = 2
        end
    end
    if player.lives == 0 then
        game.gameState = 5
    end

end

function love.draw()
    if (game.gameState == 1) then
        mainMenu()
    elseif game.gameState == 2 then
        if game.gameOver == false then
            love.graphics.draw(background,0,0)
            love.graphics.draw(player.graphic, player.xpos, player.ypos)
            for i, bullet in ipairs(bullets.aliveBullets) do
                love.graphics.draw(bullets.playerBullet.graphic, bullet.xpos, bullet.ypos)
            end
            for j, enemy in ipairs(game.aliveEnemies) do
                enemy.moveAnimation:draw(enemy.spriteSheet, enemy.xpos, enemy.ypos)
            end
            for k, effect in ipairs(game.effects) do
                effect.animation:draw(effect.spriteSheet, effect.xpos, effect.ypos)
            end
            for l, bullet in ipairs(bullets.aliveEnemyBullets) do
                love.graphics.draw(bullet.graphic, bullet.xpos, bullet.ypos)
            end
            love.graphics.print("Score: " .. game.score, 400, 50)
            love.graphics.print("Level: " .. game.currentLevel, 400, 65)
        end
    elseif game.gameState == 3 then
        love.graphics.print("Level Complete!", 400, 300)
        love.graphics.print("Score: " .. game.score, 400, 320)
        love.graphics.print("Next level in..." .. game.intermissionTimer)
    elseif game.gameState == 4 then
        love.graphics.print("Victory!", 350, 200)
        love.graphics.print("Your score: " .. game.score, 350, 250)
    elseif game.gameState == 5 then
        love.graphics.print("Game over! You lose!", 350, 200)
        love.graphics.print("Your score: " .. game.score, 350, 250)
    elseif game.gameState == 6 then
        love.graphics.print("Credits", 50, 100)
        love.graphics.print("Code: Pedro Teixeira\nArt: Pedro Teixeira\nMusic: Jay Man (Check out more at ourmusicbox.com)\nLove2D Framework: Rude (love2d.org) (ZLIB)\nAnim8 library: Kikito (github.com/kikito/anim8) (MIT License)", 50, 150)
    end
end

function love.load()
    love.window.setTitle("RailDefender")
end