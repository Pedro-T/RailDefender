--
-- Author: Pedro Teixeira
-- Date: 3/1/2016
--
enemies = {}

apc = {}
apc['graphic'] = "assets/apc.png"
apc['movementSpeed'] = 10
apc['hitpoints'] = 1
apc['shootsAtPlayer'] = false

tank = {}
tank['graphic'] = "assets/tank.png"
tank['movementSpeed'] = 15
tank['hitpoints'] = 2
tank['shootsAtPlayer'] = true
tank['shotCooldown'] = 1.5

superTank = {}
superTank['graphic'] = "assets/superTank.png"
superTank['movementSpeed'] = 10
superTank['hitpoints'] = 5
superTank['shootsAtPlayer'] = true
superTank['shotCooldown'] = 0.75

boss = {}
boss['graphic'] = "assets/boss.png"
boss['movementSpeed'] = 10
boss['hitpoints'] = 100
boss['shootsAtPlayer'] = true



table.insert(enemies, apc)
table.insert(enemies, tank)
table.insert(enemies, superTank)
table.insert(enemies, boss)

return enemies