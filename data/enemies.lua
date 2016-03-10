--
-- Author: Pedro Teixeira
-- Date: 3/2/2016
--

local anim8 = require("lib/anim8/anim8")

local enemies = {}

local apc = {}
apc['spriteSheet'] = love.graphics.newImage("assets/apc_sheet.png")
apc['animationGrid'] = anim8.newGrid(12, 15, apc.spriteSheet:getWidth(), apc.spriteSheet:getHeight())
apc['moveAnimation'] = anim8.newAnimation(apc.animationGrid('1-4', 1), 0.3)
apc['deathAnimation'] = anim8.newAnimation(apc.animationGrid('1-4', 2), 0.3)
apc.deathAnimation.onLoop = "pauseAtEnd"
apc['movementSpeed'] = 45
apc['hitpoints'] = 1
apc['xSize'] = 12
apc['ySize'] = 15
apc['shootsAtPlayer'] = false

local tank = {}
tank['graphic'] = "assets/tank.png"
tank['movementSpeed'] = 25
tank['hitpoints'] = 2
tank['shootsAtPlayer'] = true
tank['shotCooldown'] = 1.5

local superTank = {}
superTank['graphic'] = "assets/superTank.png"
superTank['movementSpeed'] = 15
superTank['hitpoints'] = 5
superTank['shootsAtPlayer'] = true
superTank['shotCooldown'] = 0.75

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