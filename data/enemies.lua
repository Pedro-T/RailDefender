--
-- Author: Pedro Teixeira
-- Date: 3/20/2016
--

local anim8 = require("lib/anim8/anim8")

local enemies = {}

local apc = {}
apc['spriteSheet'] = love.graphics.newImage("assets/apc_sheet.png")
apc['xSize'] = 12
apc['ySize'] = 15
apc['animationGrid'] = anim8.newGrid(apc.xSize, apc.ySize, apc.spriteSheet:getWidth(), apc.spriteSheet:getHeight())
apc['moveAnimation'] = anim8.newAnimation(apc.animationGrid('1-4', 1), 0.3)
apc['deathAnimation'] = anim8.newAnimation(apc.animationGrid('1-5', 2), 0.2)
apc.deathAnimation.onLoop = "pauseAtEnd"
apc['movementSpeed'] = 45
apc['hitpoints'] = 1
apc['shootsAtPlayer'] = false
apc['hasAccuarateFire'] = false

local tank = {}
tank['spriteSheet'] = love.graphics.newImage("assets/tank_sheet.png")
tank['xSize'] = 24
tank['ySize'] = 32
tank['animationGrid'] = anim8.newGrid(tank.xSize, tank.ySize, tank.spriteSheet:getWidth(), tank.spriteSheet:getHeight())
tank['moveAnimation'] = anim8.newAnimation(tank.animationGrid('1-5', 1), 0.4)
tank['deathAnimation'] = anim8.newAnimation(tank.animationGrid('1-5', 2), 0.2)
tank.deathAnimation.onLoop = "pauseAtEnd"
tank['movementSpeed'] = 25
tank['hitpoints'] = 2
tank['bulletSpeed'] = 75
tank['shootsAtPlayer'] = true
tank['shotCooldown'] = 3
tank['shotInterval'] = 6
tank['hasAccuarateFire'] = false

local superTank = {}
superTank['spriteSheet'] = love.graphics.newImage("assets/superTank_sheet.png")
superTank['xSize'] = 32
superTank['ySize'] = 40
superTank['animationGrid'] = anim8.newGrid(superTank.xSize, superTank.ySize, superTank.spriteSheet:getWidth(), superTank.spriteSheet:getHeight())
superTank['moveAnimation'] = anim8.newAnimation(superTank.animationGrid('1-4', 1), 0.4)
superTank['deathAnimation'] = anim8.newAnimation(superTank.animationGrid('1-5', 2), 0.2)
superTank.deathAnimation.onLoop = "pauseAtEnd"
superTank['movementSpeed'] = 15
superTank['hitpoints'] = 5
superTank['shootsAtPlayer'] = true
superTank['shotInterval'] = 10
superTank['hasAccuarateFire'] = true

local boss = {}
boss['graphic'] = "assets/boss.png"
boss['movementSpeed'] = 10
boss['hitpoints'] = 100
boss['shootsAtPlayer'] = true



table.insert(enemies, apc)
table.insert(enemies, tank)
table.insert(enemies, superTank)
table.insert(enemies, boss)

return enemies