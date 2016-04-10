--
-- Author: Pedro Teixeira
-- Date: 4/8/2016
--

local anim8 = require("lib/anim8/anim8")

local enemies = {}

local apc = {
    spriteSheet = love.graphics.newImage("assets/apc_sheet.png"),
    xSize = 12,
    ySize = 15,
    movementSpeed = 45,
    hitpoints = 1,
    shootsAtPlayer = false,
    hasAccurateFire = false,
    pointValue = 5
}
apc.animationGrid = anim8.newGrid(apc.xSize, apc.ySize, apc.spriteSheet:getWidth(), apc.spriteSheet:getHeight())
apc.moveAnimation = anim8.newAnimation(apc.animationGrid('1-4', 1), 0.3)
apc.deathAnimation = anim8.newAnimation(apc.animationGrid('1-5', 2), 0.2)
apc.deathAnimation.onLoop = "pauseAtEnd"

local tank = {
    spriteSheet = love.graphics.newImage("assets/tank_sheet.png"),
    xSize = 24,
    ySize = 32,
    movementSpeed = 25,
    hitpoints = 2,
    shootsAtPlayer = true,
    hasAccurateFire = false,
    bulletGraphic = love.graphics.newImage("assets/tankShot.png"),
    bulletSpeed = 65,
    shotCooldown = 10,
    shotInterval = 10,
    pointValue = 10
}
tank.animationGrid = anim8.newGrid(tank.xSize, tank.ySize, tank.spriteSheet:getWidth(), tank.spriteSheet:getHeight())
tank.moveAnimation = anim8.newAnimation(tank.animationGrid('1-5', 1), 0.4)
tank.deathAnimation = anim8.newAnimation(tank.animationGrid('1-5', 2), 0.2)
tank.deathAnimation.onLoop = "pauseAtEnd"


local superTank = {
    spriteSheet = love.graphics.newImage("assets/superTank_sheet.png"),
    xSize = 32,
    ySize = 40,
    movementSpeed = 15,
    hitpoints = 5,
    shootsAtPlayer = true,
    hasAccurateFire = true,
    bulletGraphic = love.graphics.newImage("assets/tankShot.png"),
    bulletSpeed = 100,
    shotCooldown = 15,
    shotInterval = 15,
    pointValue = 10
}

superTank.animationGrid = anim8.newGrid(superTank.xSize, superTank.ySize, superTank.spriteSheet:getWidth(), superTank.spriteSheet:getHeight())
superTank.moveAnimation = anim8.newAnimation(superTank.animationGrid('1-4', 1), 0.4)
superTank.deathAnimation = anim8.newAnimation(superTank.animationGrid('1-5', 2), 0.2)
superTank.deathAnimation.onLoop = "pauseAtEnd"


table.insert(enemies, apc)
table.insert(enemies, tank)
table.insert(enemies, superTank)

return enemies