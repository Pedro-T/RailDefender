--
-- Author: Pedro Teixeira
-- Date: 3/25/16
--

local bullets = {}

bullets.playerBullet = {}
bullets.playerBullet.graphic = love.graphics.newImage("assets/playerBullet.png")
bullets.playerBullet.movementSpeed = 300
bullets.playerBullet.damage = 1

bullets.aliveBullets = {}
bullets.aliveEnemyBullets = {}



bullets.fireBullet = function(player)
    if (player.shotCooldown == 0) then
        local bullet = {}
        bullet.graphic = bullets.playerBullet.graphic
        bullet.movementSpeed = bullets.playerBullet.movementSpeed
        bullet['xpos'] = player.xpos + (player.graphic:getWidth()/2 - bullets.playerBullet.graphic:getWidth() / 2)
        bullet['ypos'] = player.ypos
        player.shotCooldown = 0.25
        table.insert(bullets.aliveBullets, bullet)
    end
end

bullets.fireEnemyBullet = function (player, enemy, delta)
    if enemy.shotCooldown <= 0 then
        local bullet = {}
        bullet['xpos'] = enemy.xpos
        bullet['ypos'] = enemy.ypos
        bullet['graphic'] = enemy.bulletGraphic
        if enemy.hasAccurateFire then
            local angle = math.atan((player.ypos + player.width / 2) - (enemy.ypos + enemy.width / 2), (player.xpos + player.width / 2) - (enemy.xpos + enemy.width / 2))
            bullet['dx'] = enemy.bulletSpeed * math.cos(angle)
            bullet['dy'] = enemy.bulletSpeed * math.sin(angle)
        else
            bullet['dx'] = 0
            bullet['dy'] = enemy.bulletSpeed
        end
        enemy.shotCooldown = enemy.shotInterval
        table.insert(bullets.aliveEnemyBullets, bullet)
    else
        enemy.shotCooldown = enemy.shotCooldown - delta
    end
end

bullets.checkHit = function (shot, unit)
    return ((shot.xpos < unit.xpos + unit.xSize) and (shot.xpos + shot.graphic:getWidth() > unit.xpos) and (shot.ypos < unit.ypos + unit.ySize) and (shot.ypos + shot.graphic:getHeight() > unit.ypos))
end

bullets.updateBullets = function(player, delta, game)
    for i, bullet in ipairs(bullets.aliveBullets) do
        bullets.aliveBullets[i].ypos = bullets.aliveBullets[i].ypos - (bullets.playerBullet.movementSpeed * delta)
        if (bullet.ypos < -10) then
            table.remove(bullets.aliveBullets, i)
        end
        for j, enemy in ipairs(game.aliveEnemies) do
            if bullets.checkHit(bullet, enemy) then
                enemy.hitpoints = enemy.hitpoints - 1
                if enemy.hitpoints <= 0 then
                    table.remove(game.aliveEnemies, j)
                    game.deadEnemies = game.deadEnemies + 1
                    game.score = game.score + enemy.pointValue
                    local effect = {}
                    effect.animation = enemy.deathAnimation:clone()
                    effect.spriteSheet = enemy.spriteSheet
                    effect.xpos = enemy.xpos
                    effect.ypos = enemy.ypos
                    table.insert(game.effects, effect)
                end
                table.remove(bullets.aliveBullets, i)
            end
        end
    end
    for k, bullet in ipairs(bullets.aliveEnemyBullets) do
        bullet.xpos = bullet.xpos + (bullet.dx * delta)
        bullet.ypos = bullet.ypos + (bullet.dy * delta)
        if (bullet.ypos < -10) then
            table.remove(bullets.aliveEnemyBullets, k)
        end
        if (bullets.checkHit(bullet, player)) then
            player.loseLife()
            table.remove(bullets.aliveEnemyBullets, k)
        end
    end
end


return bullets